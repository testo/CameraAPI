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
#ifndef CAM_CONNECTOR
#define CAM_CONNECTOR

#include "TiLibExternInterface.h"
#include <string>
#include <vector>
#include <externinterface/IrCamera.h>

#include "IrCamera.h"


/** @class CamConnector
 ******************************************************************************************************
Simple interface classe to connect the camera with minimal header includes.
It can be used for extern liberary interface.
 
@kuj (2015)
*****************************************************************************************************/

namespace testo
{
  namespace ti
  {
    class TILIB_EXTERN_INTERFACE_DECL CamConnector
    {
    public:
      /** @function getListOfCameras
      ******************************************************************************************************
      get a list with serial and a list with camera type string of all found devices
      @param [out] vecSerials: list with serials
      @param [out] vecDeviceType: list with device types

      @retrun true if any camera was found
      *****************************************************************************************************/
      static bool getListOfCameras(std::vector<uint32_t>& vecSerials, std::vector<std::string>& vecDeviceType);

      /** @function open
      ******************************************************************************************************
      open a camera with a given serial
      @param [in] serial

      @retrun camera object
      *****************************************************************************************************/
      static IrCamera open(uint32_t u32Serial);

      /** @function open
      ******************************************************************************************************
      close camera factory destry all camera handler

      use this before unload the communication dll to end the use of the factory.

      All camera objects must be closed in advance!
      *****************************************************************************************************/
      static void closeCameraInterface();
    };
  }
} 
#endif