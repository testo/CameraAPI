#ifndef C_CONNECTOR_H
#define C_CONNECTOR_H

/***************************************************************************
* INCLUDES
***************************************************************************/

#include <CameraApi/labview_cwrapper/Labview_cwrapperConfig.h>
#include <string>


#if defined (__cplusplus)
extern "C" {
#endif

/***************************************************************************
* C FUNCTION DEFINITIONS
***************************************************************************/

/**
**************************************************************************
get all camera serials that are connected
@param [out] u32NumberOfCameras - number of cameras = size of serial array
@param [out] pscurrentDeviceIds - pointer to deviceId strings
@param [out] u8Error - returns 1 if failed, 2 if no cameras were found, 0 if succesfull

@return pointer uint32_t array with all camera serials that were found
        returns nullptr if no camera was found
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL const uint32_t* getCameraSerials(uint32_t* u32NumberOfCameras, char** psCurrentDeviceIds, uint8_t* u8Error);

/**
**************************************************************************
open connection to camera chosen by serial number
@param [in] u32Serial - serial number of camera

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t openCamera(uint32_t u32Serial);

/**
**************************************************************************
close connection of current camera

@return uint8_t function success state
returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t closeCamera();

/**
**************************************************************************
get current emissivity value
@param [out] fEmissivity - current emissivity value

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull

*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getEmissivity(float* fEmissivity);

/**
**************************************************************************
set emissivity value
@param [in] fValue - emissivity value

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t setEmissivity(float fValue);

/**
**************************************************************************
get current reflected temperature

@param [out] fRefTemp - current reflected temperature value

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getReflectedTemperature(float* fRefTemp);

/**
**************************************************************************
set reflected temperature
@param [in] fValue - reflected temperature

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t  setReflectedTemperature(float fValue);

/**
**************************************************************************
atmosphere correction state
@param [out] u32Serial - get atmosphere correction state, 0 if OFF, 1 if ON

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getAtmosphereCorrectionState(uint8_t* u8AtmosCorr);

/**
**************************************************************************
set atmosphere correction state
@param [in] uint8_t - atmosphere correction, 0 if OFF, 1 if ON

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t setAtmosphereCorrectionState(uint8_t u8Value);

/**
**************************************************************************
get current humidty value
@param [out] fValue - current humdity value

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getHumidiy(float* fHumidity);

/**
**************************************************************************
set humidity value
@param [in] fValue - humidity value to use

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t setHumidiy(float fValue);

/**
**************************************************************************
get current measurement range
@param [out] u32MeasRange - current measurement range

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getMeasurementRange(uint32_t* u32MeasRange);

/**
**************************************************************************
set measurement range to use
@param [in] uint32_t - measurement range to use

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t setMeasurementRange(uint32_t u32MeasRange);

/**
**************************************************************************
get number of measurement ranges
@param [out] uint32_t - number of measurement ranges

@return uint8_t function success state
    returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getNumberOfMeasurementRanges(uint32_t* u32NumMeasRange);

/**
**************************************************************************
capture VIS image from camera
@param [out] au8ChannelB - uint8_t array for B-channel
@param [out] au8ChannelG - uint8_t array for G-channel
@param [out] au8ChannelG - uint8_t array for R-channel

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t captureVis(uint8_t* au8ChannelB, uint8_t* au8ChannelG, uint8_t* au8ChannelR, int32_t* i32VisHeight, int32_t* i32VisWidth);

/**
**************************************************************************
capture IR image from camera
@param [out] au8ChannelB - uint8_t array for B-channel
@param [out] au8ChannelG - uint8_t array for G-channel
@param [out] au8ChannelG - uint8_t array for R-channel
@param [in] u8PaletteType - palette type for temperature color palette

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t captureIr(uint8_t* au8ChannelB, uint8_t* au8ChannelG, uint8_t* au8ChannelR, int32_t* i32IrHeight, int32_t* i32IrWidth, uint8_t u8PaletteType, float* pfFloatMat);

/**
**************************************************************************
get atmosphere temperature

@return uint8_t function success state
returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t getAtmosphereTemperature(float* fAtmosTemp);

/**
**************************************************************************
set atmosphere temperature value
@param [in] float - atmosphere temperature value to set 

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t setAtmosphereTemperature(float fValue);

/**
**************************************************************************
get 2D temperature float matrix
@param [out] pfFloatMat - float array for temperature float values
@param [out] i32IrHeight- pointer to variable containing height of IR image
@param [out] i32IrWidth - pointer to variable containing width of IR image

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t get2DTemperatureArray(float* pfFloatMat, int32_t* i32IrHeight, int32_t* i32IrWidth);

/**
**************************************************************************
stops IR stream

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t stopStreamIr();

/**
**************************************************************************
stops VIS stream

@return uint8_t function success state
        returns 1 if failed, 0 if succesfull
*************************************************************************/
CAMERAAPI_LABVIEW_CWRAPPER_DECL uint8_t stopStreamVis();


/**
**************************************************************************
write to log file
@param [in] strOutputMessage - output message
@param [in] u8Error - error state
*************************************************************************/
void writeToLogFile(std::string strOutputMessage, uint8_t u8Error);

#if defined (__cplusplus)
}
#endif

#endif