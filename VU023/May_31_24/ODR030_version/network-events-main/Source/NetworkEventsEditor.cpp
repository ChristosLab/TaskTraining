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

#include "NetworkEventsEditor.h"
#include "NetworkEvents.h"

#include <stdio.h>

NetworkEventsEditor::NetworkEventsEditor(NetworkEvents* parentNode)
    : GenericEditor(parentNode)

{
	desiredWidth = 180;
    
    processor = parentNode;

	restartConnection = std::make_unique<UtilityButton>("Restart Connection", Font("Fira Code", "Regular", 15.0f));
    restartConnection->setBounds(20,45,130,18);
    restartConnection->addListener(this);
    addAndMakeVisible(restartConnection.get());
    
    urlLabel = std::make_unique<Label>("Port", "Port:");
    urlLabel->setBounds(20,85,140,25);
    addAndMakeVisible(urlLabel.get());

	labelPort = std::make_unique<Label>("Port", processor->getCurrPortString());
    labelPort->setBounds(70,85,80,18);
    labelPort->setColour(Label::textColourId, Colours::white);
    labelPort->setColour(Label::backgroundColourId, Colours::grey);
    labelPort->setEditable(true);
    labelPort->addListener(this);
    addAndMakeVisible(labelPort.get());
}



void NetworkEventsEditor::buttonClicked(Button* button)
{
	if (button == restartConnection.get())
	{
		processor->restartConnection();
	}
}

void NetworkEventsEditor::setLabelColor(juce::Colour color)
{
	labelPort->setColour(Label::backgroundColourId, color);
}


void NetworkEventsEditor::setPortText(const String& text)
{
    labelPort->setText(text, dontSendNotification);
}


void NetworkEventsEditor::labelTextChanged(juce::Label *label)
{
    if (label == labelPort.get())
    {
        NetworkEvents *p = (NetworkEvents *)getProcessor();
        
        uint16 port;
        if (!portFromString(label->getText(), &port))
        {
            CoreServices::sendStatusMessage("NetworkEvents: Invalid port");
            setPortText(p->getCurrPortString());
            return;
        }

        p->setNewListeningPort(port);
	}
}


NetworkEventsEditor::~NetworkEventsEditor()
{

}


bool NetworkEventsEditor::portFromString(const String& portString, uint16* port)
{
    if (portString.trim() == "*") // wildcard, special case
    {
        *port = 0;
        return true;
    }

    if (portString.indexOfAnyOf("0123456789") == -1)
    {
        return false;
    }

    int32 portInput = portString.getIntValue();
    if (portInput <= 0 || portInput > (1 << 16) - 1)
    {
        return false;
    }
    *port = static_cast<uint16>(portInput);
    return true;
}
