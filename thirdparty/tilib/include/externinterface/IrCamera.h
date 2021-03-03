/***************************************************************************
* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
***************************************************************************/
/**@file
   @brief<b>Description: </b> CamConnector class

   <br> $Author: 1000len-kuj $
   <br> $Date: 2012-10-25 14:10:46 +0200 (Do, 25 Okt 2012) $
   <br> $HeadURL: http://testosvn01/repos/pl/tilib/branches/stable-1.5/modules/datatypes/MarkedFloat.h $
   <br> $Revision: 52380 $

 ***************************************************************************/
#ifndef IR_CAMERA
#define IR_CAMERA

#include "TiLibExternInterface.h"
#include <string>
#include <memory>

#include <opencv2/core/core.hpp>

namespace tipi
{
  // forward delcaration of intern camera interface class
  class CamProcessBase;
}

/** @class IrCamera
 ******************************************************************************************************
Simple interface class to control and capture images from an ir camera (t885, t890)
This class is not multithreading save!
 
@kuj (2015)
*****************************************************************************************************/
namespace testo
{
  namespace ti
  {
    class TILIB_EXTERN_INTERFACE_DECL IrCamera
    {
      // only the CamConnector can create a IrCamera class
      friend class CamConnector;

    public:
      /**
      **************************************************************************
      empty constructor only useable to create a dummy (not connected object)
      will not throw any exception
      *************************************************************************/
      IrCamera();

      virtual ~IrCamera();

      uint32_t getSerial();
      std::string getDeviceType();

      /**
      **************************************************************************
      captures one radiometric calculated ir frame from the camera
      framerate about 1fps

      @return flaot mat with temperature values for each pixel
      *************************************************************************/
      cv::Mat captureIr();

      void stopIr();

      /**
      **************************************************************************
      captures one visual frame from the camera

      @return 8-Bit RGB mat
      *************************************************************************/
      cv::Mat_<cv::Vec3b> captureVis();

      void stopVis();

      /**
      **************************************************************************
      Parameter
      *************************************************************************/
      uint32_t getMeasurementRange();
      void setMeasurementRange(uint32_t u32MeasRange);
      uint32_t getNumberOfMeasurementRanges();

      float getEmissivity();
      void setEmissivity(float fValue);

      float getReflectedTemperature();
      void setReflectedTemperature(float fValue);

      bool getAtmosphereCurrectionState();
      void setAtmosphereCurrectionState(bool bEnable);

      float getAtmosphereTemperature();
      void setAtmosphereTemperature(float fTemperature);

      float getHumidiy();
      void setHumidiy(float fValue);

      float getDistance();
      void setDistance(float fValue);

    private:
      // only private contructor
      IrCamera(std::shared_ptr<tipi::CamProcessBase> pInternInterface);

      // try to get cal data from file system (same files from IrSoft)
      bool loadCalDataFromFile(const std::string& strCombindedHash);
      // try to save caldata to a file (in IrSoft format)
      void saveCalDataToFile(const std::string& strCombindedHash);

      void checkInterface();

      std::shared_ptr<tipi::CamProcessBase> m_pInternInterface;

      bool bVisStreamActive;
      bool bIrStreamActive;
    };
  }  
}
#endif