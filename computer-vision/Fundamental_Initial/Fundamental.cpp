// Imagine++ project
// Project:  Fundamental
// Author:   Pascal Monasse

#include "./Imagine/Features.h"
#include <Imagine/Graphics.h>
#include <Imagine/LinAlg.h>
#include <vector>
#include <cstdlib>
#include <ctime>
using namespace Imagine;
using namespace std;

static const float BETA = 0.01f; // Probability of failure

struct Match {
    float x1, y1, x2, y2;
};

// Display SIFT points and fill vector of point correspondences
void algoSIFT(Image<Color,2> I1, Image<Color,2> I2,
              vector<Match>& matches) {
    // Find interest points
    SIFTDetector D;
    D.setFirstOctave(-1);
    Array<SIFTDetector::Feature> feats1 = D.run(I1);
    drawFeatures(feats1, Coords<2>(0,0));
    cout << "Im1: " << feats1.size() << flush;
    Array<SIFTDetector::Feature> feats2 = D.run(I2);
    drawFeatures(feats2, Coords<2>(I1.width(),0));
    cout << " Im2: " << feats2.size() << flush;

    const double MAX_DISTANCE = 100.0*100.0;
    for(size_t i=0; i < feats1.size(); i++) {
        SIFTDetector::Feature f1=feats1[i];
        for(size_t j=0; j < feats2.size(); j++) {
            double d = squaredDist(f1.desc, feats2[j].desc);
            if(d < MAX_DISTANCE) {
                Match m;
                m.x1 = f1.pos.x();
                m.y1 = f1.pos.y();
                m.x2 = feats2[j].pos.x();
                m.y2 = feats2[j].pos.y();
                matches.push_back(m);
            }
        }
    }
}

// Randomly select a number of matches
vector<Match> selectRandomMatches(int numberPairs, vector<Match>& matches) {
    vector<Match> selectedMatches(numberPairs);
    vector<int> indices;
    
    while (indices.size() < numberPairs) {
        auto rand_idx = intRandom(0, matches.size() - 1);
        if ( find(indices.begin(), indices.end(), rand_idx) == indices.end() ) {
            indices.push_back(rand_idx);
        }
    }
    for (int i=0; i < numberPairs; i++) {
        selectedMatches[i] = matches[indices[i]];
    }
    return selectedMatches;
}

vector<int> computeInliers(FMatrix<float, 3, 3> F, vector<Match>& matches, float distMax) {
    FVector<float, 3> x, xTilde;
    vector<int> inliers;
    float dist;
    for (int i=0; i < matches.size(); i++) {
        x[0] = matches[i].x1;
        x[1] = matches[i].y1;
        x[2] = 1;
        xTilde[0] = matches[i].x2;
        xTilde[1] = matches[i].y2;
        xTilde[2] = 1;

        FVector<float, 3> Fx = F * x;
        dist = abs(Fx[0] * xTilde[0] + Fx[1] * xTilde[1] + Fx[2] * xTilde[2]);
        dist /= sqrt(pow(Fx[0], 2) + pow(Fx[1], 2)); 
        if (dist < distMax) {
            inliers.push_back(i);
        }
    }
    return inliers;
}

// Returns the fundamental matrix F for a given set of selected matching points
FMatrix<float, 3, 3> solveF(vector<Match> selectedMatches) {
    const int numberPairs = selectedMatches.size(); 
    const float NORM_COEFF = 1e-3;
    FMatrix<float, 3, 3> N;
    N.fill(0);
    N(0, 0) = NORM_COEFF;
    N(1, 1) = NORM_COEFF; 
    N(2, 2) = 1; 

    Matrix<float> A(numberPairs, 9);
    for(int i=0; i < numberPairs; i++) {
        Match m = selectedMatches[i]; 
        float x1 = m.x1 * NORM_COEFF;
        float y1 = m.y1 * NORM_COEFF;

        float x2 = m.x2 * NORM_COEFF;
        float y2 = m.y2 * NORM_COEFF;

        A(i, 0) = x2 * x1;
        A(i, 1) = x2 * y1;
        A(i, 2) = x2;
        A(i, 3) = y2 * x1;
        A(i, 4) = y2 * y1;
        A(i, 5) = y2;
        A(i, 6) = x1;
        A(i, 7) = y1;
        A(i, 8) = 1;
    }    
    // SVD on A to find optimal F (last column of Vt)
    Matrix<float> U(numberPairs, numberPairs);
    Matrix<float> Vt(9,9);
    Vector<float> diag_S(numberPairs);
    svd(A, U, diag_S, Vt);

    FMatrix<float, 3, 3> F;
    F(0,0) = Vt(8,0); 
    F(0,1) = Vt(8,1); 
    F(0,2) = Vt(8,2); 
    F(1,0) = Vt(8,3); 
    F(1,1) = Vt(8,4); 
    F(1,2) = Vt(8,5); 
    F(2,0) = Vt(8,6); 
    F(2,1) = Vt(8,7); 
    F(2,2) = Vt(8,8); 

    // SVD on F to enforce rank 2
    FMatrix<float, 3, 3> U_f;
    FMatrix<float, 3, 3> Vt_f;
    FVector<float, 3> diag_S_f;
    svd(F, U_f, diag_S_f, Vt_f);
    FMatrix<float, 3, 3> S_f;
    S_f.fill(0);
    S_f(0,0) = diag_S_f[0];
    S_f(1,1) = diag_S_f[1];
    F = N * U_f * S_f * Vt_f * N;
    return F;
}

// RANSAC algorithm to compute F from point matches (8-point algorithm)
// Parameter matches is filtered to keep only inliers as output.
FMatrix<float,3,3> computeF(vector<Match>& matches) {
    const float distMax = 1.5f; // Pixel error for inlier/outlier discrimination
    int Niter=100000; // Adjusted dynamically
    FMatrix<float,3,3> bestF;
    vector<int> bestInliers;
    // --------------- TODO ------------
    // DO NOT FORGET NORMALIZATION OF POINTS
    const int numberPairs = 8;
    int totalIterations=0;

    cout << "RANSAC starting..." << endl;
    while (totalIterations < Niter) {
        auto selectedMatches = selectRandomMatches(numberPairs, matches);
        auto F = solveF(selectedMatches);
        auto currentInliers = computeInliers(F, matches, distMax);
        if (currentInliers.size() >= bestInliers.size()) {
            bestInliers = currentInliers;
            bestF = F;
            float n = matches.size();
            float m = bestInliers.size();
            if (m > 50) {
                int New = log(BETA) / log(1 - pow(m / n, 8));
                Niter = min(Niter, New); 
            }
        }
        totalIterations += 1;
    }

    // Updating matches with inliers only
    vector<Match> all=matches;
    matches.clear();
    for(size_t i=0; i<bestInliers.size(); i++)
        matches.push_back(all[bestInliers[i]]);
    bestF = solveF(matches);
    return bestF;
}

// Expects clicks in one image and show corresponding line in other image.
// Stop at right-click.
void displayEpipolar(Image<Color> I1, Image<Color> I2,
                    const FMatrix<float,3,3>& F) { 
    while(true) {
        int x,y;
        if(getMouse(x,y) == 3)
            break;
        // --------------- TODO ------------
        IntPoint2 point{x, y};

        if (x <= I1.width()) {
            FVector<int, 3> X{x, y, 1};
            auto epipolarLineRight = F * X;
            float a = -epipolarLineRight[0] / epipolarLineRight[1];
            float b = -epipolarLineRight[2] / epipolarLineRight[1];
            float x1 = 0;
            float y1 = b;
            float x2 = I2.width();
            float y2 = a * x2 + b;

            // Offset to imageRight (I2)
            x1 += I1.width();
            x2 += I1.width();
            drawLine(x1, y1, x2, y2, RED);
            drawCircle(point, 2, RED);
        }
        else {
            // Offset to imageLeft (I1)
            FVector<int, 3> XTilde{x - I1.width(), y, 1};
            auto epipolarLineLeft = transpose(F) * XTilde;
            float a = -epipolarLineLeft[0] / epipolarLineLeft[1];
            float b = -epipolarLineLeft[2] / epipolarLineLeft[1];
            float x1 = 0;
            float y1 = b;
            float x2 = I1.width();
            float y2 = a * x2 + b;
            drawLine(x1, y1, x2, y2, BLUE);
            drawCircle(point, 2, BLUE);
        }
        
    }
}

int main(int argc, char* argv[])
{
    srand((unsigned int)time(0));

    const char* s1 = argc>1? argv[1]: srcPath("im1.jpg");
    const char* s2 = argc>2? argv[2]: srcPath("im2.jpg");

    // Load and display images
    Image<Color,2> I1, I2;
    if( ! load(I1, s1) ||
        ! load(I2, s2) ) {
        cerr<< "Unable to load images" << endl;
        return 1;
    }
    int w = I1.width();
    openWindow(2*w, I1.height());
    display(I1,0,0);
    display(I2,w,0);

    vector<Match> matches;
    algoSIFT(I1, I2, matches);
    const int n = (int)matches.size();
    cout << " matches: " << n << endl;
    drawString(100,20,std::to_string(n)+ " matches",RED);
    click();
    
    FMatrix<float,3,3> F = computeF(matches);
    cout << "F="<< endl << F;

    // Redisplay with matches
    display(I1,0,0);
    display(I2,w,0);
    for(size_t i=0; i<matches.size(); i++) {
        Color c(rand()%256,rand()%256,rand()%256);
        fillCircle(matches[i].x1+0, matches[i].y1, 2, c);
        fillCircle(matches[i].x2+w, matches[i].y2, 2, c);        
    }
    drawString(100, 20, to_string(matches.size())+"/"+to_string(n)+" inliers", RED);
    click();

    // Redisplay without SIFT points
    display(I1,0,0);
    display(I2,w,0);
    displayEpipolar(I1, I2, F);

    endGraphics();
    return 0;
}
