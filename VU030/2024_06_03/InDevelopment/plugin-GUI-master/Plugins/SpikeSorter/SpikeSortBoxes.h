/*
------------------------------------------------------------------

This file is part of the Open Ephys GUI
Copyright (C) 2013 Open Ephys

------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef __SPIKESORTBOXES_H
#define __SPIKESORTBOXES_H

#include "SpikeSorterEditor.h"
#include <algorithm>    // std::sort
#include <list>
#include <queue>
#include <atomic>

class SorterSpikeContainer : public ReferenceCountedObject
{
public:
	//This invalidates the original SpikeEventPtr, so be careful
	SorterSpikeContainer(const SpikeChannel* channel, SpikeEvent::SpikeBuffer& data, int64 timestamp);
	SorterSpikeContainer() = delete;

	const float* getData() const;
	const SpikeChannel* getChannel() const;
	int64 getTimestamp() const;
	uint8 color[3];
	float pcProj[2];
	uint16 sortedId;
private:
	int64 timestamp;
	HeapBlock<float> data;
	const SpikeChannel* chan;
};
typedef ReferenceCountedObjectPtr<SorterSpikeContainer> SorterSpikePtr;
typedef ReferenceCountedArray<SorterSpikeContainer, CriticalSection> SorterSpikeArray;

class PCAcomputingThread;
class UniqueIDgenerator;
class PointD
{
public:

    PointD();
    PointD(float x, float y);
    PointD(const PointD& P);
    const PointD operator+(const PointD& c1) const;
    PointD& operator+=(const PointD& rhs);
    PointD& operator-=(const PointD& rhs);


    const PointD operator-(const PointD& c1) const;
    const PointD operator*(const PointD& c1) const;

    float cross(PointD c) const;
    float X,Y;
};


class Box
{
public:
    Box();
    Box(int channel);
    Box(float X, float Y, float W, float H, int ch=0);
    bool LineSegmentIntersection(PointD p11, PointD p12, PointD p21, PointD p22);
    bool isWaveFormInside(SorterSpikePtr so);
    double x,y,w,h; // x&w and specified in microseconds. y&h in microvolts
    int channel;
};


/************************/
class Histogram
{
public:
    Histogram();
    Histogram(int N, double T0, double T1);
    ~Histogram();

    void setParameters(int N, double T0, double T1);
    std::vector<int> getCounter();
    void reset();
    void update(double x);

    int Max;
    double t0, t1;
    std::vector<double> Time;
    int numBins;
    std::vector<int> Counter;

};

class RunningStats
{
public:
    RunningStats();
    ~RunningStats();
    void resizeWaveform(int newlength);
    void reset();
    Histogram getHistogram();
    std::vector<double> getMean(int index);
    std::vector<double> getStandardDeviation(int index);
    void update(SorterSpikePtr so);
    bool queryNewData();

    double LastSpikeTime;
    bool newData;
    Histogram hist;
    std::vector<std::vector<double> > WaveFormMean,WaveFormSk,WaveFormMk;
    double numSamples;


};

// Box unit defines a single unit (with multiple boxes)
// Each box can be on a different channel
class BoxUnit
{
public:
    BoxUnit();
    BoxUnit(int ID, int localID);
    BoxUnit(Box B, int ID, int localID);
    bool isWaveFormInsideAllBoxes(SorterSpikePtr so);
    bool isActivated();
    void activateUnit();
    void deactivateUnit();
    double getNumSecondsActive();
    void toggleActive();
    void addBox(Box b);
    void addBox();
    int getNumBoxes();
    void modifyBox(int boxindex, Box b);
    bool deleteBox(int boxindex);
    Box getBox(int box);
    void setBox(int boxid, Box B);
    void setBoxPos(int boxid, PointD P);
    void setBoxSize(int boxid, double W, double H);
    void MoveBox(int boxid, int dx, int dy);
    std::vector<Box> getBoxes();
    int getUnitID();
    int getLocalID();
	void updateWaveform(SorterSpikePtr so);
    static void setDefaultColors(uint8_t col[3], int ID);
    void resizeWaveform(int newlength);
public:
    int UnitID;
    int localID; // used internally, for colors and position.
    std::vector<Box> lstBoxes;
    uint8_t ColorRGB[3];
    RunningStats WaveformStat;
    bool Active;
    juce::int64 Activated_TS_S;
    Time timer;

};

/*
class PCAjob
{
public:
PCAjob();
};*/
class PCAjob : public ReferenceCountedObject
{
public:
    PCAjob(SorterSpikeArray& _spikes, float* _pc1, float* _pc2,
           std::atomic<float>&,  std::atomic<float>&,  std::atomic<float>&,  std::atomic<float>&, std::atomic<bool>& _reportDone);
    ~PCAjob();
    void computeCov();
    void computeSVD();

    float** cov;
    SorterSpikeArray spikes;
    float* pc1, *pc2;
    std::atomic<float>& pc1min, &pc2min, &pc1max, &pc2max;
    std::atomic<bool>& reportDone;
private:
    int svdcmp(float** a, int nRows, int nCols, float* w, float** v);
    float pythag(float a, float b);
    int dim;
};

typedef ReferenceCountedObjectPtr<PCAjob> PCAJobPtr;
typedef ReferenceCountedArray<PCAjob, CriticalSection> PCAJobArray;

class cPolygon
{
public:
    cPolygon();
    bool isPointInside(PointD p);
    std::vector<PointD> pts;
    PointD offset;
};



class PCAcomputingThread : juce::Thread
{
public:
    PCAcomputingThread();
    void run(); // computes PCA on waveforms
    void addPCAjob(PCAJobPtr job);

private:
    PCAJobArray jobs;
	CriticalSection lock;
};

class PCAUnit
{
public:
    PCAUnit();
    PCAUnit(int ID, int localID);
    PCAUnit(cPolygon B, int ID, int localID_);
    ~PCAUnit();
    int getUnitID();
    int getLocalID();
	bool isWaveFormInsidePolygon(SorterSpikePtr so);
    bool isPointInsidePolygon(PointD p);
    void resizeWaveform(int newlength);
	void updateWaveform(SorterSpikePtr so);
public:
    int UnitID;
    int localID; // used internally, for colors and position.
    cPolygon poly;
    uint8_t ColorRGB[3];
    RunningStats WaveformStat;
    bool Active;
    juce::int64 Activated_TS_S;
    Time timer;
};

// Sort spikes from a single electrode (which could have any number of channels)
// using the box method. Any electrode could have an arbitrary number of units specified.
// Each unit is defined by a set of boxes, which can be placed on any of the given channels.
class SpikeSortBoxes
{
public:
    SpikeSortBoxes(UniqueIDgenerator* uniqueIDgenerator_, PCAcomputingThread* pth, int numch, double SamplingRate, int WaveFormLength);
    ~SpikeSortBoxes();

    void resizeWaveform(int numSamples);


	void projectOnPrincipalComponents(SorterSpikePtr so);
	bool sortSpike(SorterSpikePtr so, bool PCAfirst);
    void RePCA();
    void addPCAunit(PCAUnit unit);
    int addBoxUnit(int channel);
    int addBoxUnit(int channel, Box B);

    void getPCArange(float& p1min,float& p2min, float& p1max,  float& p2max);
    void setPCArange(float p1min,float p2min, float p1max,  float p2max);
    void resetJobStatus();
    bool isPCAfinished();

    bool removeUnit(int unitID);

    void removeAllUnits();
    bool addBoxToUnit(int channel, int unitID);
    bool addBoxToUnit(int channel, int unitID, Box B);
    bool removeBoxFromUnit(int unitID, int boxIndex);
    int getNumBoxes(int unitID);
    std::vector<Box> getUnitBoxes(int unitID);
    std::vector<BoxUnit> getBoxUnits();
    std::vector<PCAUnit> getPCAUnits();

    void getUnitColor(int UnitID, uint8& R, uint8& G, uint8& B);
    void updateBoxUnits(std::vector<BoxUnit> _units);
    void updatePCAUnits(std::vector<PCAUnit> _units);
    int generateUnitID();
    int generateLocalID();
    void generateNewIDs();
    void setSelectedUnitAndBox(int unitID, int boxID);
    void getSelectedUnitAndBox(int& unitID, int& boxid);
    void saveCustomParametersToXml(XmlElement* electrodeNode);
    void loadCustomParametersFromXml(XmlElement* electrodeNode);
private:
    //void  StartCriticalSection();
    //void  EndCriticalSection();
    UniqueIDgenerator* uniqueIDgenerator;
    int numChannels, waveformLength;
    int selectedUnit, selectedBox;
    CriticalSection mut;
    std::vector<BoxUnit> boxUnits;
    std::vector<PCAUnit> pcaUnits;
    float* pc1, *pc2;
    std::atomic<float> pc1min, pc2min, pc1max, pc2max;
    SorterSpikeArray spikeBuffer;
    int bufferSize,spikeBufferIndex;
    PCAcomputingThread* computingThread;
    bool bPCAJobSubmitted,bPCAcomputed,bRePCA;
    std::atomic<bool> bPCAjobFinished ;


};

//Those are legacy methods from the old spike system that are must likely not needed in the new one
float spikeDataBinToMicrovolts(SorterSpikePtr  s, int bin, int ch = 0);
float spikeDataIndexToMicrovolts(SorterSpikePtr s, int index = 0);
float spikeTimeBinToMicrosecond(SorterSpikePtr s, int bin, int ch = 0);
int microSecondsToSpikeTimeBin(SorterSpikePtr s, float t, int ch = 0);


#endif // __SPIKESORTBOXES_H
