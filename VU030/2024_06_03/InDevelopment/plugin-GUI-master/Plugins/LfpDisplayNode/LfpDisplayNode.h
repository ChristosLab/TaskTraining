/*
    ------------------------------------------------------------------

    This file is part of the Open Ephys GUI
    Copyright (C) 2016 Open Ephys

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

#ifndef __LFPDISPLAYNODE_H_Alpha__
#define __LFPDISPLAYNODE_H_Alpha__

#include <ProcessorHeaders.h>
#include "LfpDisplayEditor.h"
#include "LfpDisplayCanvas.h"
#include "DisplayBuffer.h"

#include <map>

class DataViewport;

namespace LfpViewer
{

/**

  Holds data in a displayBuffer to be used by the LfpDisplayCanvas
  for rendering continuous data streams.

  @see GenericProcessor, LfpDisplayEditor, LfpDisplayCanvas

*/
class LfpDisplayNode :  public GenericProcessor

{
public:
    LfpDisplayNode();
    ~LfpDisplayNode();

    AudioProcessorEditor* createEditor() override;

    void process (AudioSampleBuffer& buffer) override;

    void setParameter (int parameterIndex, float newValue) override;

    void updateSettings() override;

    bool enable()   override;
    bool disable()  override;

    void handleEvent (const EventChannel* eventInfo, const MidiMessage& event, int samplePosition = 0) override;

    //std::shared_ptr<AudioSampleBuffer> getDisplayBufferAddress(int bufferIndex) const 
    //{ 
    //    return displayBuffers[bufferIndex]; // displayBuffers[inputSubprocessors.indexOf(subprocessorToDraw[splitId])];
    //}

    //int getDisplayBufferIndex (int chan, int splitId) const 
    //{ 
    //    return displayBufferIndices[inputSubprocessors.indexOf(subprocessorToDraw[splitId])][chan]; 
    //}

    //SortedSet<uint32> inputSubprocessors;
    String getSubprocessorName(int ch); // { return subprocessorNames[sn]; }

    Array<DisplayBuffer*> getDisplayBuffers();
    std::map<uint32, DisplayBuffer*> displayBufferMap;

    void setSplitDisplays(Array<LfpDisplaySplitter*>);

   // void setSubprocessor(uint32 sp, int splitId); // should not be needed
   // uint32 getSubprocessor(int splitId) const; // should not be needed
   // void setDefaultSubprocessors(); // should not be needed
    
    //int getNumSubprocessorChannels(int splitId);

   // float getSubprocessorSampleRate(uint32 subprocId);

    //uint32 getDataSubprocId(int chan) const;

   // void setNumberOfDisplays(int num); // should not be needed

    void setTriggerSource(int ch, int splitId); 
    int getTriggerSource(int splitId) const;
    int64 getLatestTriggerTime(int splitId) const;
    void acknowledgeTrigger(int splitId);
private:
    void initializeEventChannels();
    void finalizeEventChannels();

    //std::vector<std::shared_ptr<DisplayBuffer>> displayBuffers;
    
    OwnedArray<DisplayBuffer> displayBuffers;

    Array<LfpDisplaySplitter*> splitDisplays;


   // std::vector<std::vector<int>> displayBufferIndices;
    //Array<int> channelIndices;

    //Array<uint32> eventSourceNodes;

   // float displayGain; //
   // float bufferLength; // s

    //std::map<uint32, uint64> ttlState;
    //float* arrayOfOnes;
    //int totalSamples;
    
    //int numDisplays; // total number of split displays

   // Array<int> triggerSource;

    Array<int> triggerChannels;
    Array<int64> latestTrigger; // overall timestamp
    Array<int> latestCurrentTrigger; // within current input buffer

    //HashMap<int, String> subprocessorNames;
    //void updateInputSubprocessors();
    
    //bool resizeBuffer();

    //int numSubprocessors;
    //Array<uint32> subprocessorToDraw;
 
    //std::map<uint32, int> numChannelsInSubprocessor;
    //std::map<uint32, float> subprocessorSampleRate;


    static uint32 getEventSourceId(const EventChannel* event);
    static uint32 getChannelSourceId(const InfoObjectCommon* chan);

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(LfpDisplayNode);
};
};



#endif  // __LFPDISPLAYNODE_H_Alpha__
