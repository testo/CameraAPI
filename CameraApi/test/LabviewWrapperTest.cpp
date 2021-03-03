#include <iostream>
#include <thread>
#include <chrono>

#include <labview_cwrapper/c_connector.h>


/* GTest */
// ignore warning C4275: non dll-interface class 'testing::TestPartResultReporterInterface' used as base for dll-interface class 'testing::internal::HasNewFatalFailureHelper'
// ignore warning C4251: 'testing::internal::TypedTestCasePState::defined_test_names_' : class 'std::set<_Kty>' needs to have dll-interface to be used by clients of class 'testing::internal::TypedTestCasePState'
#pragma warning(push)
#pragma warning(disable:4275)
#pragma warning(disable:4251)
#include <gtest/gtest.h>
#pragma warning(pop)


TEST(LABVIEW_CWRAPPER, GetSerials)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  std::cout << "Number of connected cameras: " << u32NumberOfCameras << std::endl;

  if (u32NumberOfCameras > 0)
  {
    std::cout << "serial camera 1: " << u32Serials[0] << std::endl;
  }
  else
  {
    std::cout << "no camera attached: " << std::endl;
  }
}

TEST(LABVIEW_CWRAPPER, openCamera)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));

  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  for (uint32_t u32 = 0; u32 < u32NumberOfCameras; u32++)
  {
    ASSERT_NO_THROW(u8Error = openCamera(u32Serials[u32]));
    std::cout << "open camera: " << u32Serials[u32] << std::endl;
  }
}

TEST(LABVIEW_CWRAPPER, Emissivity)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  float fEmissivity(0.0f);
  float fChangedEmissivity(0.0f);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = getEmissivity(&fEmissivity));
  EXPECT_EQ(0, u8Error);

  std::cout << "Current emissivity: " << fEmissivity << std::endl;
  ASSERT_NO_THROW(u8Error = setEmissivity(0.43f));
  EXPECT_EQ(0, u8Error);

  ASSERT_NO_THROW(u8Error = getEmissivity(&fChangedEmissivity));
  EXPECT_NEAR(0.43f, fChangedEmissivity, 0.0001);
  EXPECT_EQ(0, u8Error);
  std::cout << "change emissivity to: " << fChangedEmissivity << std::endl;

  ASSERT_NO_THROW(u8Error = setEmissivity(fEmissivity));
  EXPECT_EQ(0, u8Error);
  std::cout << "set emissivity back to: " << fEmissivity << std::endl;
}

TEST(LABVIEW_CWRAPPER, ReflectedTemperature)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  float fReflectedTemperature(0.0f);
  float fChangedReflectedTemperature(0.0f);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";


  ASSERT_NO_THROW(u8Error = getReflectedTemperature(&fReflectedTemperature));
  EXPECT_EQ(0, u8Error);

  std::cout << "Current ReflectedTemperature: " << fReflectedTemperature << std::endl;
  ASSERT_NO_THROW(u8Error = setReflectedTemperature(22.0f));
  EXPECT_EQ(0, u8Error);

  ASSERT_NO_THROW(u8Error = getReflectedTemperature(&fChangedReflectedTemperature));
  EXPECT_NEAR(22.0f, fChangedReflectedTemperature, 0.0001);
  EXPECT_EQ(0, u8Error);
  std::cout << "change ReflectedTemperature to: " << fChangedReflectedTemperature << std::endl;

  ASSERT_NO_THROW(u8Error = setReflectedTemperature(fReflectedTemperature));
  EXPECT_EQ(0, u8Error);
  std::cout << "set ReflectedTemperature back to: " << fReflectedTemperature << std::endl;
}

TEST(LABVIEW_CWRAPPER, AtmosphereCorrectionState)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  uint8_t u8AtmosphereCorrectionState(0);
  uint8_t u8ChangedAtmosphereCorrectionState(0);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = getAtmosphereCorrectionState(&u8AtmosphereCorrectionState));
  EXPECT_EQ(0, u8Error);

  std::cout << "Current AtmosphereCorrectionState: " << u8AtmosphereCorrectionState << std::endl;
  ASSERT_NO_THROW(u8Error = setAtmosphereCorrectionState(0));
  EXPECT_EQ(0, u8Error);

  ASSERT_NO_THROW(u8Error = getAtmosphereCorrectionState(&u8ChangedAtmosphereCorrectionState));
  EXPECT_EQ(0, u8ChangedAtmosphereCorrectionState);
  EXPECT_EQ(0, u8Error);
  std::cout << "change AtmosphereCorrectionState to: " << u8ChangedAtmosphereCorrectionState << std::endl;

  ASSERT_NO_THROW(u8Error = setAtmosphereCorrectionState(u8AtmosphereCorrectionState));
  EXPECT_EQ(0, u8Error);
  std::cout << "set AtmosphereCorrectionState back to: " << u8AtmosphereCorrectionState << std::endl;
}

TEST(LABVIEW_CWRAPPER, Humidiy)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  float fHumidiy(0.0f);
  float fChangedHumidiy(0.0f);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = getHumidiy(&fHumidiy));
  EXPECT_EQ(0, u8Error);

  std::cout << "Current Humidiy: " << fHumidiy << std::endl;
  ASSERT_NO_THROW(u8Error = setHumidiy(42.0f));
  EXPECT_EQ(0, u8Error);

  ASSERT_NO_THROW(u8Error = getHumidiy(&fChangedHumidiy));
  EXPECT_NEAR(42.0f, fChangedHumidiy, 0.0001);
  EXPECT_EQ(0, u8Error);
  std::cout << "change Humidiy to: " << fChangedHumidiy << std::endl;

  ASSERT_NO_THROW(u8Error = setHumidiy(fHumidiy));
  EXPECT_EQ(0, u8Error);
  std::cout << "set Humidiy back to: " << fHumidiy << std::endl;
}

TEST(LABVIEW_CWRAPPER, NumberOfMeasurementRanges)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  uint32_t u32NumberOfMeasurementRanges(0);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = getNumberOfMeasurementRanges(&u32NumberOfMeasurementRanges));
  EXPECT_EQ(0, u8Error);
  ASSERT_GE(u32NumberOfMeasurementRanges, 1U);
  std::cout << "Current NumberOfMeasurementRanges: " << u32NumberOfMeasurementRanges << std::endl;
}

TEST(LABVIEW_CWRAPPER, MeasurementRange)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  uint32_t u32MeasurementRange(0);
  //uint32_t u32ChangedMeasurementRange(0);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";
  ASSERT_NO_THROW(u8Error = getMeasurementRange(&u32MeasurementRange));
  EXPECT_EQ(0, u8Error);

  // Timeout if measurement range changing.
  //
  //std::cout << "Current MeasurementRange: " << u32MeasurementRange << std::endl;
  //ASSERT_NO_THROW(u8Error = setMeasurementRange(u32MeasurementRange+1));
  //EXPECT_EQ(0, u8Error);

  //ASSERT_NO_THROW(u8Error = getMeasurementRange(&u32ChangedMeasurementRange));
  //EXPECT_EQ(u32MeasurementRange+1, u32ChangedMeasurementRange);
  //EXPECT_EQ(0, u8Error);
  //std::cout << "change MeasurementRange to: " << u32ChangedMeasurementRange << std::endl;

  //ASSERT_NO_THROW(u8Error = setMeasurementRange(u32MeasurementRange));
  //EXPECT_EQ(0, u8Error);
  //std::cout << "set MeasurementRange back to: " << u32MeasurementRange << std::endl;
}

TEST(LABVIEW_CWRAPPER, captureVis)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  //uint8_t au8ChannelB, au8ChannelG, au8ChannelR;
  //int32_t i32VisHeight(0), i32VisWidth(0);


  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";
  // unknown malloc size at this point
  //
  //ASSERT_NO_THROW(u8Error = captureVis(&au8ChannelB, &au8ChannelG, &au8ChannelR, &i32VisHeight, &i32VisWidth));
  //EXPECT_EQ(0, u8Error);
  //std::cout << "Current VisHeight: " << i32VisHeight << std::endl;
  //std::cout << "Current VisWidth: " << i32VisWidth << std::endl;
  std::cout << "no camera attached: " << std::endl;
}

TEST(LABVIEW_CWRAPPER, captureIr)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  //uint8_t au8ChannelB, au8ChannelG, au8ChannelR;
  //int32_t i32IrHeight(0), i32IrWidth(0);
  //uint8_t u8PaletteType(0);
  //float pfFloatMat(0.0);


  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  // unknown malloc size at this point
  //
  //ASSERT_NO_THROW(u8Error = captureIr(&au8ChannelB, &au8ChannelG, &au8ChannelR, &i32IrHeight, &i32IrWidth, &u8PaletteType, &pfFloatMat));
  //EXPECT_EQ(0, u8Error);
  //std::cout << "Current IrHeight: " << i32IrHeight << std::endl;
  //std::cout << "Current IrWidth: " << i32IrWidth << std::endl;
}

TEST(LABVIEW_CWRAPPER, AtmosphereTemperature)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;
  float fAtmosphereTemperature(0.0f);
  float fChangedAtmosphereTemperature(0.0f);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = getAtmosphereTemperature(&fAtmosphereTemperature));
  EXPECT_EQ(0, u8Error);

  std::cout << "Current AtmosphereTemperature: " << fAtmosphereTemperature << std::endl;
  ASSERT_NO_THROW(u8Error = setAtmosphereTemperature(16.0f));
  EXPECT_EQ(0, u8Error);

  ASSERT_NO_THROW(u8Error = getAtmosphereTemperature(&fChangedAtmosphereTemperature));
  EXPECT_NEAR(16.0f, fChangedAtmosphereTemperature, 0.0001);
  EXPECT_EQ(0, u8Error);
  std::cout << "change AtmosphereTemperature to: " << fChangedAtmosphereTemperature << std::endl;

  ASSERT_NO_THROW(u8Error = setAtmosphereTemperature(fAtmosphereTemperature));
  EXPECT_EQ(0, u8Error);
  std::cout << "set AtmosphereTemperature back to: " << fAtmosphereTemperature << std::endl;
}

TEST(LABVIEW_CWRAPPER, get2DTemperatureArray)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds(0);
  uint8_t u8Error;
  //float* pfFloatMat;
  //int32_t i32IrHeight(0), i32IrWidth(0);
  //int32_t i32IrHeightPre(0), i32IrWidthPre(0);

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  // unknown malloc size at this point
  //
  //pfFloatMat = (float*)malloc(i32IrHeight * i32IrWidth);
  //ASSERT_NO_THROW(u8Error = get2DTemperatureArray(&pfFloatMat, &i32IrHeight, &i32IrWidth));
  //EXPECT_EQ(0, u8Error);
  //std::cout << "Current IrHeight: " << i32IrHeight << std::endl;
  //std::cout << "Current IrWidth: " << i32IrWidth << std::endl;
}

TEST(LABVIEW_CWRAPPER, stopStreamIr)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = stopStreamIr());
  EXPECT_EQ(0, u8Error);
  std::cout << "stopStreamIr: " << std::endl;
}

TEST(LABVIEW_CWRAPPER, stopStreamVis)
{
  uint32_t u32NumberOfCameras(0);
  const uint32_t* u32Serials(nullptr);
  char* psCurrentDeviceIds;
  uint8_t u8Error;

  ASSERT_NO_THROW(u32Serials = getCameraSerials(&u32NumberOfCameras, &psCurrentDeviceIds, &u8Error));
  ASSERT_GE(u32NumberOfCameras, 1U) << "No camera attached!";

  ASSERT_NO_THROW(u8Error = stopStreamVis());
  EXPECT_EQ(0, u8Error);
  std::cout << "stopStreamVis: " << std::endl;
  std::cout << "no camera attached: " << std::endl;
  ASSERT_NO_THROW(closeCamera());
}

int main(int argc, char *argv[])
{
  ::testing::InitGoogleTest(&argc, argv);
  int res = RUN_ALL_TESTS();
  return	res;
}