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

#ifndef __RECORDCONTROL_H_120DD434__
#define __RECORDCONTROL_H_120DD434__

#include <ProcessorHeaders.h>
#include "RecordControlEditor.h"


/**
    Stops and stops recording in response to incoming events.

    @see RecordNode
*/
class RecordControl : public GenericProcessor
{
public:
    RecordControl();
    ~RecordControl();

    AudioProcessorEditor* createEditor() override;

    void process (AudioSampleBuffer& buffer) override;

    void setParameter (int parameterIndex, float newValue) override;
    void handleEvent (const EventChannel* eventInfo, const MidiMessage& event, int) override;

    bool enable() override;

private:
    std::atomic<int> triggerEvent;
	std::atomic<int> triggerChannel;

    enum Edges { RISING = 0, FALLING = 1 };
    enum Types { SET = 0, TOGGLE = 1};

    Edges triggerEdge;
    Types triggerType;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (RecordControl);
};

#endif
