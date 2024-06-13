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
#ifndef __LFPDISPLAYOPTIONS_H__
#define __LFPDISPLAYOPTIONS_H__

#include <VisualizerWindowHeaders.h>

#include <vector>
#include <array>

#include "LfpDisplayClasses.h"
#include "LfpDisplayNode.h"
namespace LfpViewer {
#pragma  mark - LfpDisplayOptions -
//==============================================================================
/**
 
    Holds the LfpDisplay UI controls
 
 */
class LfpDisplayOptions : public Component,
    public Slider::Listener,
    public ComboBox::Listener,
    public Button::Listener
{
public:
    LfpDisplayOptions(LfpDisplayCanvas*,
                      LfpDisplaySplitter*, 
                      LfpTimescale*, 
                      LfpDisplay*, 
                      LfpDisplayNode*);
    ~LfpDisplayOptions();

    void paint(Graphics& g);
    void resized();

    void setRangeSelection(float range, bool canvasMustUpdate = false); // set range selection combo box to correct value if it has been changed by scolling etc.
    void setSpreadSelection(int spread, bool canvasMustUpdate = false, bool deferDisplayRefresh = false); // set spread selection combo box to correct value if it has been changed by scolling etc.

    void comboBoxChanged(ComboBox* cb);
    void buttonClicked(Button* button);
    
    /** Changes the timebase value used by LfpTimescale and LfpDisplayCanvas. */
    void setTimebaseAndSelectionText(float timebase);
    
    /** Handles slider events for all editors. */
    void sliderValueChanged(Slider* sl);
    
    /** Called by sliderValueChanged(). Deals with clicks on custom sliders. Subclasses
     of GenericEditor should modify this method only.*/
    void sliderEvent(Slider* sl);

    int getChannelHeight();
    bool getDrawMethodState();
    bool getInputInvertedState();
	bool getChannelNameState();
    
    /** Return a bool describing whether the spike raster functionality is enabled */
    bool getDisplaySpikeRasterizerState();
    
    /** Sets the state of the spike raster functionality on/off */
    void setDisplaySpikeRasterizerState(bool isEnabled);

    //void setRangeSelection(float range, bool canvasMustUpdate);
    void setSpreadSelection();

    void togglePauseButton(bool sendUpdate = true);

    void saveParameters(XmlElement* xml);
    void loadParameters(XmlElement* xml);

	DataChannel::DataChannelTypes getChannelType(int n);
	DataChannel::DataChannelTypes getSelectedType();
    String getTypeName(DataChannel::DataChannelTypes type);
	int getRangeStep(DataChannel::DataChannelTypes type);

	void setSelectedType(DataChannel::DataChannelTypes type, bool toggleButton = true);

    int selectedSpread;
    String selectedSpreadValue;

    int selectedTimebase;
    String selectedTimebaseValue;

    int selectedOverlap;
    String selectedOverlapValue;
    
    int selectedChannelDisplaySkip;
    String selectedChannelDisplaySkipValue;
    
    int selectedSpikeRasterThreshold;
    String selectedSpikeRasterThresholdValue;

    // this enum is a candidate option for refactoring, not used yet
    enum ChannelDisplaySkipValue {
        None = 0,
        One,
        Two,
        Four,
        Eight,
        Sixteen,
        ThirtyTwo
    } enum_selectedChannelDisplaySkipValue = None;
    
    int selectedSaturation; // for saturation warning
    String selectedSaturationValue;
    float selectedSaturationValueFloat; // TODO: this is way ugly - we should refactor all these parameters soon and get them into a nicer format- probably when we do the general plugin parameter overhaul.

    void setChannelsReversed(bool);
    void setInputInverted(bool);
    void setMedianOffset(bool);
    void setAveraging(bool);
    void setSortByDepth(bool);
    void setShowChannelNumbers(bool);

private:

    LfpDisplayCanvas* canvas;
    LfpDisplaySplitter* canvasSplit;
    LfpDisplay* lfpDisplay;
    LfpTimescale* timescale;
    LfpDisplayNode* processor;
    
    Font labelFont;
    Colour labelColour;

    // Main options
    ScopedPointer<ComboBox> timebaseSelection;
    ScopedPointer<ComboBox> spreadSelection;
    ScopedPointer<ComboBox> rangeSelection;
    OwnedArray<UtilityButton> typeButtons;
    
    ScopedPointer<ComboBox> overlapSelection; // what do we do with this?
    
    OwnedArray<EventDisplayInterface> eventDisplayInterfaces;
    ScopedPointer<UtilityButton> pauseButton;
    ScopedPointer<ComboBox> colourSchemeOptionSelection;
    ScopedPointer<ComboBox> colorGroupingSelection;
    
    ScopedPointer<ShowHideOptionsButton> showHideOptionsButton;

    // THRESHOLDS SECTION
    ScopedPointer<ComboBox> spikeRasterSelection;
    ScopedPointer<ComboBox> saturationWarningSelection; // optionally raise hell if the actual data is saturating
    ScopedPointer<ComboBox> clipWarningSelection; // optinally draw (subtle) warning if data is clipped in display
    
    // CHANNELS SECTION
    ScopedPointer<UtilityButton> reverseChannelsDisplayButton;
    ScopedPointer<UtilityButton> sortByDepthButton;
    ScopedPointer<ComboBox> channelDisplaySkipSelection;
    ScopedPointer<UtilityButton> showChannelNumberButton;

    // SIGNAL PROCESSING SECTION
    ScopedPointer<UtilityButton> medianOffsetPlottingButton;
    ScopedPointer<UtilityButton> invertInputButton;

    // TRIGGERED DISPLAY SECTION
    ScopedPointer<ComboBox> triggerSourceSelection;
    ScopedPointer<UtilityButton> averageSignalButton;
    ScopedPointer<UtilityButton> resetButton;
     
    StringArray voltageRanges[CHANNEL_TYPES];
    StringArray timebases;
    StringArray spreads; // option for vertical spacing between channels
    StringArray colorGroupings; // option for coloring every N channels the same
    StringArray triggerSources; // option for trigger source event channel
    StringArray overlaps; //
    StringArray saturationThresholds; //default values for when different amplifiers saturate
    StringArray clipThresholds;
    StringArray spikeRasterSelectionOptions;
    StringArray channelDisplaySkipOptions;
    StringArray sectionTitles;
    
	DataChannel::DataChannelTypes selectedChannelType;
    int selectedVoltageRange[CHANNEL_TYPES];
    String selectedVoltageRangeValues[CHANNEL_TYPES];
    float rangeGain[CHANNEL_TYPES];
    StringArray rangeUnits;
    StringArray typeNames;
    int rangeSteps[CHANNEL_TYPES];

    bool medianOffsetOnForSpikeRaster;

    // NOT USED:
    //ScopedPointer<Slider> brightnessSliderA;
    //ScopedPointer<Slider> brightnessSliderB;

    //ScopedPointer<Label> sliderALabel;
    //ScopedPointer<Label> sliderBLabel;

    // label and combobox for stream rate to be displayed (only show one or other)
    //ScopedPointer<Label> streamRateDisplayedLabel;
    //ScopedPointer<ComboBox> streamRateDisplayedSelection;
    //StringArray streamRateDisplayedOptions;

    // label and toggle button for the median offset plotting feature
    //ScopedPointer<Label> medianOffsetPlottingLabel;

        //ScopedPointer<UtilityButton> drawMethodButton;

    // label and toggle button for channel numbering
    //ScopedPointer<Label> showChannelNumberLabel;


    // label and combobox for color scheme options
    //ScopedPointer<Label> colourSchemeOptionLabel;
    //ScopedPointer<ComboBox> colourSchemeOptionSelection;
 

};
    
}; // namespace

#endif
