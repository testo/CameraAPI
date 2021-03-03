#include "c_connector.h"

// stl
#include <vector>
#include <iostream>
#include <fstream>
#include <list>

// tilib
#include <externinterface/CamConnector.h>
#include <externinterface/Palette.h>
#include <externinterface/IrCamera.h>

#define LOG 0

using namespace testo::ti;

/***************************************************************************
* GLOABAL VAR
***************************************************************************/

/**< vector with last found camera serials */
static std::vector<uint32_t> mg_vecCurrentSerials;

/**< vector with last found camera device ids */
static std::vector<std::string> mg_vecCurrentDeviceIds;

/**< IrCamera object with current connected Camera */
static IrCamera mg_irCamera;

/**< serial number with current connected IrCamera */
static uint32_t mg_u32OpenCamSerial = 0;

/**< matrix of RGB vectors with visual image */
static cv::Mat_<cv::Vec3b> mg_matVisImage;

/**< matrix array with visual BGR channels */
static cv::Mat mg_amatVisBGRChannel[3];

/**< matrix with float temperature values of infrared image */
static cv::Mat mg_matFloatIrImage;

/**< matrix array with visual BGR channels */
static cv::Mat_<cv::Vec3b> mg_matIrImage;

/**< matrix array with infrared BGR channels */
static cv::Mat mg_amatIrBGRChannel[3];

static int32_t g_i32IrHeight = 0;
static int32_t g_i32IrWidth = 0;
static int32_t g_i32VisHeight = 0;
static int32_t g_i32VisWidth = 0;

/***************************************************************************
* C FUNCTION IMPLEMENTATION
***************************************************************************/

const uint32_t* getCameraSerials(uint32_t* u32NumberOfCameras, char** psCurrentDeviceIds, uint8_t* u8Error)
{
    *u8Error = 1;
    uint32_t* pvecCameraSerial = nullptr;
    try
    {
      // get list of cameras
      if(CamConnector::getListOfCameras(mg_vecCurrentSerials, mg_vecCurrentDeviceIds))
      {
        *u32NumberOfCameras = mg_vecCurrentSerials.size();
        pvecCameraSerial = mg_vecCurrentSerials.data();
        *psCurrentDeviceIds = (char*)mg_vecCurrentDeviceIds.data();
        *u8Error = 0;
      }
      // no camera found
      // might be an error - used as an warning
      // needed by LabView user
      else
      {
        *u32NumberOfCameras = 0U;
        *psCurrentDeviceIds = nullptr;
        *u8Error = 2;
      } 
    }
    catch (...)
    {   
        *u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getCameraSerials", *u8Error);
        }
    }
    return pvecCameraSerial;
}

uint8_t openCamera(uint32_t u32Serial)
{
    uint8_t u8Error = 1;
    bool bOpenCamera = false;

    try
    {
        // if no camera open
        if (mg_u32OpenCamSerial == 0)
        {
            bOpenCamera = true;
        }
        // if different camera open 
        else if (mg_u32OpenCamSerial != u32Serial)
        {
            // close current camera and open new one
            closeCamera();
            bOpenCamera = true;
        }
        // if same camera open
        else if (mg_u32OpenCamSerial == u32Serial)
        {
            // do nothing
            u8Error = 0;
        }
        
        // if camera should be opened, open the one with the given serial number
        if (bOpenCamera)
        {
            mg_irCamera = CamConnector::open(u32Serial);
            mg_u32OpenCamSerial = u32Serial;
            u8Error = 0;
        }
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function openCamera", u8Error);
        }
    }
   
    return u8Error;
}

uint8_t closeCamera()
{
    uint8_t u8Error = 1;

    try
    {
        // close camera
        mg_irCamera = IrCamera();
        u8Error = 0;
        mg_u32OpenCamSerial = 0;

        // close interface
        CamConnector::closeCameraInterface();
    }
    catch (...)
    {   
        u8Error = 1;
        mg_u32OpenCamSerial = 0;
        if (LOG)
        {
            writeToLogFile("Error in function closeCamera", u8Error);
        }
    }

    return u8Error;
}

uint8_t getEmissivity(float* fEmissivity)
{
    uint8_t u8Error = 1;
        
    try
    {   // get emissivity value
        *fEmissivity = mg_irCamera.getEmissivity();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getEmissivity", u8Error);
        }
    }

    return u8Error;
}

uint8_t setEmissivity(float fValue)
{
    uint8_t u8Error = 1;

    try
    {
        // set emissivity value
        mg_irCamera.setEmissivity(fValue);
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function setEmissivity", u8Error);
        }
    }

    return u8Error; 
}

uint8_t getReflectedTemperature(float* fRefTemp)
{
    uint8_t u8Error = 1;

    try
    {
        // get reflected temperature value
        *fRefTemp = mg_irCamera.getReflectedTemperature();
        u8Error = 0 ;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getReflectedTemperature", u8Error);
        }
    }

    return u8Error;   
}

uint8_t  setReflectedTemperature(float fValue)
{
    uint8_t u8Error = 1;

    try
    {
        // set reflected temperature value
        mg_irCamera.setReflectedTemperature(fValue);
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function setReflectedTemperature", u8Error);
        }
    }
    return u8Error;
}

uint8_t setMeasurementRange(uint32_t u32MeasRange)
{
    uint8_t u8Error = 1;

    try
    {
        // set reflected temperature value
        mg_irCamera.setMeasurementRange(u32MeasRange);
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function setMeasurementRange", u8Error);
        }
    }

    return u8Error;
}

uint8_t getMeasurementRange(uint32_t* u32MeasRange)
{

    uint8_t u8Error  = 1;

    try
    {
        // get reflected temperature value
        *u32MeasRange = mg_irCamera.getMeasurementRange();
        u8Error =  0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getMeasurementRange", u8Error);
        }
    }

    return u8Error;
}


uint8_t getNumberOfMeasurementRanges(uint32_t* u32NumMeasRange)
{
    uint8_t u8Error = 1;

    try
    {
        // get reflected temperature value
        *u32NumMeasRange = mg_irCamera.getNumberOfMeasurementRanges();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getNumberOfMeasurementRanges", u8Error);
        }
    }

    return u8Error;
}

uint8_t getHumidiy(float* fHumidity)
{
    uint8_t u8Error = 1;

    try
    {
        // get humidity value
        *fHumidity = mg_irCamera.getHumidiy();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getHumidity", u8Error);
        }
    }

    return u8Error;
}

uint8_t setHumidiy(float fValue)
{
    uint8_t u8Error = 1;

    try
    {   
        // set humidity value
        mg_irCamera.setHumidiy(fValue);
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function setHumidiy", u8Error);
        }
    }

    return u8Error;
}

uint8_t getAtmosphereCorrectionState(uint8_t* u8AtmosCorr)
{
    uint8_t u8Error = 1;

    try
    {
        // get atmosphere correction state
        *u8AtmosCorr = mg_irCamera.getAtmosphereCurrectionState();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getAtmosphereCorrectionState", u8Error);
        }
    }
    return u8Error;
}


uint8_t setAtmosphereCorrectionState(uint8_t u8Value)
{
    uint8_t u8Error = 1;
    bool bValue = u8Value != 0;

    try
    {
        // set atmosphere correction state
        mg_irCamera.setAtmosphereCurrectionState(bValue);
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function setAtmosphereCorrectionState", u8Error);
        }
    }

    return u8Error;
 }


uint8_t getAtmosphereTemperature(float* fAtmosTemp)
{
    uint8_t u8Error = 1;

    try
    {
        // get humidity value
        *fAtmosTemp = mg_irCamera.getAtmosphereTemperature();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function getAtmosphereTemperature", u8Error);
        }
    }

    return u8Error;
}

uint8_t setAtmosphereTemperature(float fValue)
{
    uint8_t u8Error = 1;

    try
    {
        // set humidity value
        mg_irCamera.setAtmosphereTemperature(fValue);
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function setAtmosphereTemperature", u8Error);
        }
    }

    return u8Error;
}

uint8_t captureVis(uint8_t* au8ChannelB, uint8_t* au8ChannelG, uint8_t* au8ChannelR, int32_t* i32VisHeight, int32_t* i32VisWidth)
{
    uint8_t u8Error = 1;

    try
    {
        // get Vis Image from camera
        mg_matVisImage = mg_irCamera.captureVis();
        
        // check if resolution changed
        if (g_i32VisHeight != mg_matVisImage.rows && g_i32VisWidth != mg_matVisImage.cols)
        {
            g_i32VisHeight = mg_matVisImage.rows;
            g_i32VisWidth = mg_matVisImage.cols;
        }
        
        *i32VisHeight = g_i32VisHeight;
        *i32VisWidth = g_i32VisWidth;

        // split VIS image into BGR-channel
        cv::split(mg_matVisImage, mg_amatVisBGRChannel);

        // copy data to Labview array
        memcpy(au8ChannelB, (uint8_t*)mg_amatVisBGRChannel[0].data, g_i32VisHeight * g_i32VisWidth * sizeof(uint8_t));
        memcpy(au8ChannelG, (uint8_t*)mg_amatVisBGRChannel[1].data, g_i32VisHeight * g_i32VisWidth * sizeof(uint8_t));
        memcpy(au8ChannelR, (uint8_t*)mg_amatVisBGRChannel[2].data, g_i32VisHeight * g_i32VisWidth * sizeof(uint8_t));

        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function captureVIS", u8Error);
        }
    }
    return u8Error;
}


uint8_t captureIr(uint8_t* au8ChannelB, uint8_t* au8ChannelG, uint8_t* au8ChannelR, int32_t* i32IrHeight, int32_t* i32IrWidth ,uint8_t u8PaletteType, float* pfFloatMat)
{
    uint8_t u8Error = 1;
  
    try
    {
        // get IR image from camera
        mg_matFloatIrImage = mg_irCamera.captureIr();

        // check if resolution changed
        if (g_i32IrHeight != mg_matFloatIrImage.rows && g_i32IrWidth != mg_matFloatIrImage.cols)
        {
            g_i32IrHeight = mg_matFloatIrImage.rows;
            g_i32IrWidth = mg_matFloatIrImage.cols;
        }
        
        *i32IrHeight = g_i32IrHeight;
        *i32IrWidth = g_i32IrWidth;

        // map float values to colors
        mg_matIrImage = Palette::map(mg_matFloatIrImage, PaletteType(u8PaletteType));

        // split IR image into BGR-channel
        cv::split(mg_matIrImage, mg_amatIrBGRChannel);

        // copy data to Labview array
        memcpy(au8ChannelB, (uint8_t*)mg_amatIrBGRChannel[0].data, g_i32IrHeight * g_i32IrWidth * sizeof(uint8_t));
        memcpy(au8ChannelG, (uint8_t*)mg_amatIrBGRChannel[1].data, g_i32IrHeight * g_i32IrWidth * sizeof(uint8_t));
        memcpy(au8ChannelR, (uint8_t*)mg_amatIrBGRChannel[2].data, g_i32IrHeight * g_i32IrWidth * sizeof(uint8_t));
        
        memcpy(pfFloatMat, (float*)mg_matFloatIrImage.data, g_i32IrHeight * g_i32IrWidth * sizeof(float));
        
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function captureIr", u8Error);
        }
    }

    return u8Error;
}

uint8_t get2DTemperatureArray(float* pfFloatMat, int32_t* i32IrHeight, int32_t* i32IrWidth)
{
    uint8_t u8Error = 1;

    try
    {
        // get IR image from camera
        mg_matFloatIrImage = mg_irCamera.captureIr();

        // check if resolution changed
        if (g_i32IrHeight != mg_matFloatIrImage.rows && g_i32IrWidth != mg_matFloatIrImage.cols)
        {
            g_i32IrHeight = mg_matFloatIrImage.rows;
            g_i32IrWidth = mg_matFloatIrImage.cols;
        }

        *i32IrHeight = g_i32IrHeight;
        *i32IrWidth = g_i32IrWidth;

        // copy data from flaot Mat to Labview float Array
        memcpy(pfFloatMat, (float*)mg_matFloatIrImage.data, g_i32IrHeight * g_i32IrWidth * sizeof(float));

        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function get2DTemperatureArray", u8Error);
        }
    }

    return u8Error;
}


uint8_t stopStreamIr()
{   
    uint8_t u8Error = 1;
    try
    {
        // stop IR
        mg_irCamera.stopIr();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function stopStreamIr", u8Error);
        }
    }
   return u8Error;
}


uint8_t stopStreamVis()
{
    uint8_t u8Error = 1;
    try
    {
        // stop Vis
        mg_irCamera.stopVis();
        u8Error = 0;
    }
    catch (...)
    {
        u8Error = 1;
        if (LOG)
        {
            writeToLogFile("Error in function stopStreamVis", u8Error);
        }
    }
    return u8Error;
}

void writeToLogFile(std::string strOutputMessage, uint8_t u8Error)
{
    std::ofstream file;
    file.open(".\\protocol.txt");

    if (!std::ios_base::failbit)
    {
        file << "Error: " << u8Error << std::endl << "Message: " << strOutputMessage << std::endl;
    }

    file.close();
}


