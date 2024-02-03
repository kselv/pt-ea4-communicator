# EACommunicator API for MetaTrader

This repository contains the `EACommunicator_API.py` script, a Python-based API for connecting and communicating with the MetaTrader trading platform using the ZmqCommunicator Expert Advisor.

## File Included

- `EACommunicator_API.py` - Python script to establish a connection and communicate with MetaTrader.

## Prerequisites

Before using the `EACommunicator_API.py`, ensure the following prerequisites are met:

- MetaTrader trading platform is installed.
- ZmqCommunicator Expert Advisor is set up and running in MetaTrader.

## Setup

1. Ensure Python is installed on your system. Python 3.6 or higher is recommended.
2. Install necessary Python libraries that `EACommunicator_API.py` depends on, such as `zmq`. This can typically be done using pip:

   ```bash
   pip install zmq

## Usage

To use the `EACommunicator_API.py` library:

1. Include EACommunicator_API.py to your project and start using the endpoints.
2. Make sure Metatrader is configured with the corresponding expert advisor.

## Customization

You can customize the `EACommunicator_API.py` script to suit your specific requirements for communicating with MetaTrader. Ensure you have adequate knowledge of Python programming.

## Support

For support or to report issues with the `EACommunicator_API.py` script, please open an issue in this repository.

# Setting up ZmqCommunicator in MetaTrader

This repository contains the necessary files to set up and run the ZmqCommunicator Expert Advisor (EA) in MetaTrader.

## Files Included

- `Utils.mqh` - Utility script with helper functions for the EA.
- `ZmqCommunicatorEA.ex4` - Compiled Expert Advisor ready for use in MetaTrader.
- `ZmqCommunicatorEA.mq4` - Source code of the Expert Advisor for customization and further development.

## Installation

To install the ZmqCommunicator EA, follow these steps:

1. Copy the `ZmqCommunicatorEA.ex4`, `Utils.mqh` and `ZmqCommunicatorEA.mq4` files to the `MQL4/Experts` directory of your MetaTrader installation.
2. Make sure you have the Zmq library set up (see next section)

## Setting up the Zmq Library

The ZmqCommunicator EA requires the Zmq library to function properly. To set it up:

1. Add `Include/Zmq` (you can find it in this repo) library into your MetaTrader installation.
2. Place the content of `Libraries/*` library file into the `MQL4/Libraries` directory of your local MetaTrader installation.

## Running the Expert Advisor

After installing the EA and setting up the library, you can run the ZmqCommunicator EA by:

1. Restarting MetaTrader.
2. Opening the desired chart.
3. Attaching the `ZmqCommunicatorEA` to the chart.

Ensure that you have enabled automated trading and allowed DLL imports in MetaTrader. 
You can check in the Metatrader console output (under the "Journal" tab) if the EA is succesfully initialized.

### Successful configuration

![image](https://github.com/kselv/pt-ea4-communicator/assets/73476424/7ac3fb22-a762-4d22-a5ca-f7cedddc7458)

### Troubleshooting

![image](https://github.com/kselv/pt-ea4-communicator/assets/73476424/ea3f03e4-f8b3-4b83-851a-a691a13cc661)

![image](https://github.com/kselv/pt-ea4-communicator/assets/73476424/1ae4d4e2-91f7-45f9-bd50-9402d96362e8)

## Customization

If you wish to customize the EA, you can modify the `ZmqCommunicatorEA.mq4` file. Ensure you have adequate knowledge of MQL4 programming.


## ☕ Buy Me a Coffee
If you've found my work helpful or it has made your coding journey a bit easier, consider supporting me. Your support helps me to spend more time developing, maintaining these projects, and creating more useful tools for developers like you.

👉 [Buy Me a Coffee](https://www.buymeacoffee.com/kselv)

Every coffee counts and brings a huge smile to my face! Thank you for your support!
