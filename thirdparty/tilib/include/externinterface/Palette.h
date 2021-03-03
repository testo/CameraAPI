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
#ifndef PALETTE_H
#define PALETTE_H

#include "TiLibExternInterface.h"
#include <string>
#include <memory>

#include <opencv2/core/core.hpp>

/** @class CamConnector
 ******************************************************************************************************
 @detailed
 
Simple interface classe to connect the camera with minimal header includes.
It can be used for extern liberary interface.
 
 @kuj (2015)
 *****************************************************************************************************/
namespace testo
{
  namespace ti
  {
      enum PaletteType
      {
        PaletteTypeIron = 0,
        PaletteTypeRainbow,
        PaletteTypeBlueRed,
        PaletteTypeTesto,
        PaletteTypeSepia,
        PaletteTypeDewpoint,
        PaletteTypeRainbowHC
      };

    class TILIB_EXTERN_INTERFACE_DECL Palette
    {
    public:
      static cv::Mat_<cv::Vec3b> map(cv::Mat_<float> matImage, PaletteType palette);
    };
  }  
}
#endif