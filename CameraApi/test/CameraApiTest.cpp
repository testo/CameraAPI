#include <iostream>
#include <thread>
#include <chrono>

// tilib
#include <externinterface/CamConnector.h>
#include <externinterface/IrCamera.h>
#include <externinterface/Palette.h>

// OpenCV
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
//#include <opencv2/contrib/contrib.hpp>

/* GTest */
// ignore warning C4275: non dll-interface class 'testing::TestPartResultReporterInterface' used as base for dll-interface class 'testing::internal::HasNewFatalFailureHelper'
// ignore warning C4251: 'testing::internal::TypedTestCasePState::defined_test_names_' : class 'std::set<_Kty>' needs to have dll-interface to be used by clients of class 'testing::internal::TypedTestCasePState'
#pragma warning(push)
#pragma warning(disable:4275)
#pragma warning(disable:4251)
#include <gtest/gtest.h>
#pragma warning(pop)

using namespace testo::ti;

static void showIrOutput(const cv::Mat& matImage, float luminosity_offset = 0.2)
{
  double minVal;
  double maxVal;
  cv::Point minLoc;
  cv::Point maxLoc;

  minMaxLoc(matImage, &minVal, &maxVal, &minLoc, &maxLoc);

  minVal -= luminosity_offset*(maxVal - minVal);

  // generate a gray image that can be shown by imshow
  cv::Mat_<uint8_t> matScale = cv::Mat_<uint8_t>((matImage - minVal) / (maxVal - minVal) * 256);
  cv::imshow("IrImage", matScale);
  cv::waitKey(1);
}

static void showRgbOutput(const cv::Mat& matRgb)
{
  cv::imshow("RgbImage", matRgb);
  cv::waitKey(1);
}


TEST(ExternInterface, GetCameraList)
{
  std::vector<uint32_t> vecSerials;
  std::vector<std::string> vecDeviceType;
  ASSERT_TRUE(CamConnector::getListOfCameras(vecSerials, vecDeviceType));

  for (size_t n = 0; n < vecSerials.size(); n++)
  {
    std::cout << "serial: " << vecSerials[n] << " device type: " << vecDeviceType[n] << std::endl;
  }
}

TEST(ExternInterface, OpenCamera)
{
  std::vector<uint32_t> vecSerials;
  std::vector<std::string> vecDeviceType;
  ASSERT_TRUE(CamConnector::getListOfCameras(vecSerials, vecDeviceType));
  ASSERT_TRUE(vecSerials.size() > 0);
  ASSERT_NO_THROW(IrCamera camera = CamConnector::open(vecSerials[0]));
}

TEST(ExternInterface, OpenCameraMultipleTimes)
{
  for (size_t nCount = 0; nCount < 3; nCount++)
  {
    std::vector<uint32_t> vecSerials;
    std::vector<std::string> vecDeviceType;
    ASSERT_TRUE(CamConnector::getListOfCameras(vecSerials, vecDeviceType));
    ASSERT_TRUE(vecSerials.size() > 0);
    ASSERT_NO_THROW(IrCamera camera = CamConnector::open(vecSerials[0]));
  }
}



class CameraExtInterface : public ::testing::Test
{
protected:
  static void SetUpTestCase();
  static void TearDownTestCase();
  virtual void SetUp();

  static IrCamera m_camera;
};

IrCamera CameraExtInterface::m_camera;

void CameraExtInterface::SetUpTestCase()
{
  std::vector<uint32_t> vecSerials;
  std::vector<std::string> vecDeviceType;
  ASSERT_TRUE(CamConnector::getListOfCameras(vecSerials, vecDeviceType));
  ASSERT_TRUE(vecSerials.size() > 0);
  ASSERT_NO_THROW(m_camera = CamConnector::open(vecSerials[0]));
}

void CameraExtInterface::TearDownTestCase()
{
  // close camera object overwrite with dummy to release shared pointer
  m_camera = IrCamera();
}

void CameraExtInterface::SetUp()
{
  // nothing jet
}




TEST_F(CameraExtInterface, GetParameter)
{
  uint32_t u32NumMeasRange(0);
  ASSERT_NO_THROW(u32NumMeasRange = m_camera.getNumberOfMeasurementRanges());
  std::cout << "number of measurement ranges: " << u32NumMeasRange << std::endl;

  uint32_t u32MeasRange(0);
  ASSERT_NO_THROW(u32MeasRange = m_camera.getMeasurementRange());
  std::cout << "Current measurement range: " << u32MeasRange << std::endl;

  float fHumidity(0.0f);
  ASSERT_NO_THROW(fHumidity = m_camera.getHumidiy());
  std::cout << "Current relative humidity: " << fHumidity << std::endl;

  float fEmissivity(0.0f);
  ASSERT_NO_THROW(fEmissivity = m_camera.getEmissivity());
  std::cout << "Current emissivity: " << fEmissivity << std::endl;

  float fReflectedTemperature(0.0f);
  ASSERT_NO_THROW(fReflectedTemperature = m_camera.getReflectedTemperature());
  std::cout << "Current reflected temperature: " << fReflectedTemperature << std::endl;

  float fDistance(0.0f);
  ASSERT_NO_THROW(fDistance = m_camera.getDistance());
  std::cout << "Current distance to object: " << fDistance << std::endl;

  bool bState(false);
  ASSERT_NO_THROW(bState = m_camera.getAtmosphereCurrectionState());
  std::cout << (bState ? "Atmosphere currection enabled" : "Atmosphere currection disabled") << std::endl;

  float fAtmosphereTemperature(0.0f);
  ASSERT_NO_THROW(fAtmosphereTemperature = m_camera.getAtmosphereTemperature());
  std::cout << "Current atmosphere temperature: " << fAtmosphereTemperature << std::endl;
}


TEST_F(CameraExtInterface, ChangeParameter)
{
  uint32_t u32NumMeasRange(0);
  ASSERT_NO_THROW(u32NumMeasRange = m_camera.getNumberOfMeasurementRanges());

  uint32_t u32MeasRange(0);
  ASSERT_NO_THROW(u32MeasRange = m_camera.getMeasurementRange());
  std::cout << "Current measurement range: " << u32MeasRange << std::endl;

  if (u32NumMeasRange > 1)
  {
    // change range to an other value
    uint32_t u32NewMeasRange(u32MeasRange + 1);
    if (u32NewMeasRange >= u32NumMeasRange) u32NewMeasRange = 0;
    std::cout << "change measurement range to: " << u32NewMeasRange << "...";
    ASSERT_NO_THROW(m_camera.setMeasurementRange(u32NewMeasRange));
    uint32_t u32NewMeasRangeComp(0);
    ASSERT_NO_THROW(u32NewMeasRangeComp = m_camera.getMeasurementRange());
    EXPECT_EQ(u32NewMeasRange, u32NewMeasRangeComp);
    std::cout << "..done" << std::endl;

    // set back to original measurement range
    std::cout << "set back measurement range to: " << u32MeasRange << "...";
    ASSERT_NO_THROW(m_camera.setMeasurementRange(u32MeasRange));
    std::cout << "..done" << std::endl;
  }

  // humidity
  float fHumidity(0.0f);
  ASSERT_NO_THROW(fHumidity = m_camera.getHumidiy());
  std::cout << "Current relative humidity: " << fHumidity << std::endl;

  ASSERT_NO_THROW(m_camera.setHumidiy(55.0f));
  float fChangedHumidity(0.0f);
  ASSERT_NO_THROW(fChangedHumidity = m_camera.getHumidiy());
  EXPECT_NEAR(55.0f, fChangedHumidity, 0.01);
  std::cout << "change relative humidity to: " << fChangedHumidity << std::endl;

  ASSERT_NO_THROW(m_camera.setHumidiy(fHumidity));
  std::cout << "set relative humidity back to: " << fHumidity << std::endl;


  // emissivity
  float fEmissivity(0.0f);
  ASSERT_NO_THROW(fEmissivity = m_camera.getEmissivity());
  std::cout << "Current emissivity: " << fEmissivity << std::endl;

  ASSERT_NO_THROW(m_camera.setEmissivity(0.80f));
  float fChangedEmissivity(0.0f);
  ASSERT_NO_THROW(fChangedEmissivity = m_camera.getEmissivity());
  EXPECT_NEAR(0.80f, fChangedEmissivity, 0.0001);
  std::cout << "change emissivity to: " << fChangedEmissivity << std::endl;

  ASSERT_NO_THROW(m_camera.setEmissivity(fEmissivity));
  std::cout << "set emissivity back to: " << fEmissivity << std::endl;

  // relfected temperature
  float fReflectedTemperature(0.0f);
  ASSERT_NO_THROW(fReflectedTemperature = m_camera.getReflectedTemperature());
  std::cout << "Current reflected temperature: " << fReflectedTemperature << std::endl;

  ASSERT_NO_THROW(m_camera.setReflectedTemperature(30.0f));
  float fChangedReflectedTemperature(0.0f);
  ASSERT_NO_THROW(fChangedReflectedTemperature = m_camera.getReflectedTemperature());
  EXPECT_NEAR(30.0f, fChangedReflectedTemperature, 0.01);
  std::cout << "change reflected temperature to: " << fChangedReflectedTemperature << std::endl;

  ASSERT_NO_THROW(m_camera.setReflectedTemperature(fReflectedTemperature));
  std::cout << "set reflected temperature back to: " << fReflectedTemperature << std::endl;

  // distance
  float fDistance(0.0f);
  ASSERT_NO_THROW(fDistance = m_camera.getDistance());
  std::cout << "Current distance to object: " << fDistance << std::endl;

  ASSERT_NO_THROW(m_camera.setDistance(50.0f));
  float fChangedDistance(0.0f);
  ASSERT_NO_THROW(fChangedDistance = m_camera.getDistance());
  EXPECT_NEAR(50.0f, fChangedDistance, 0.01);
  std::cout << "change distance to object to: " << fChangedDistance << std::endl;

  ASSERT_NO_THROW(m_camera.setDistance(fDistance));
  std::cout << "set distance to object back to: " << fDistance << std::endl;

  // ATM active
  bool bState(false);
  ASSERT_NO_THROW(bState = m_camera.getAtmosphereCurrectionState());
  std::cout << (bState ? "Atmosphere currection enabled" : "Atmosphere currection disabled") << std::endl;

  ASSERT_NO_THROW(m_camera.setAtmosphereCurrectionState(!bState));
  bool bChangedState(false);
  ASSERT_NO_THROW(bChangedState = m_camera.getAtmosphereCurrectionState());
  std::cout << "change atmosphere currection\n";
  std::cout << (bChangedState ? "Atmosphere currection enabled" : "Atmosphere currection disabled") << std::endl;
  std::this_thread::sleep_for(std::chrono::milliseconds(1000));
  ASSERT_NO_THROW(m_camera.setAtmosphereCurrectionState(bState));
  std::cout << "set atmosphere currection back" << std::endl;

  // atmosphere temperature
  float fAtmosphereTemperature(0.0f);
  ASSERT_NO_THROW(fAtmosphereTemperature = m_camera.getAtmosphereTemperature());
  std::cout << "Current Atmosphere temperature: " << fAtmosphereTemperature << std::endl;

  ASSERT_NO_THROW(m_camera.setAtmosphereTemperature(45.0f));
  float fChangedAtmosphereTemperature(0.0f);
  ASSERT_NO_THROW(fChangedAtmosphereTemperature = m_camera.getAtmosphereTemperature());
  EXPECT_NEAR(45.0f, fChangedAtmosphereTemperature, 0.01);
  std::cout << "change Atmosphere temperature to: " << fChangedAtmosphereTemperature << std::endl;

  ASSERT_NO_THROW(m_camera.setAtmosphereTemperature(fAtmosphereTemperature));
  std::cout << "set Atmosphere temperature back to: " << fAtmosphereTemperature << std::endl;
}

TEST_F(CameraExtInterface, SetInvalidEmissivity)
{
  float fEmissivity(0.0f);
  ASSERT_NO_THROW(fEmissivity = m_camera.getEmissivity());
  std::cout << "Current emissivity: " << fEmissivity << std::endl;

  ASSERT_THROW(m_camera.setEmissivity(0.0f), std::exception);
  ASSERT_THROW(m_camera.setEmissivity(2.0f), std::exception);

  float fChangedEmissivity(0.0f);
  ASSERT_NO_THROW(fChangedEmissivity = m_camera.getEmissivity());
  EXPECT_NEAR(fEmissivity, fChangedEmissivity, 0.0001);
  std::cout << "emissivity still: " << fChangedEmissivity << std::endl;
}

TEST_F(CameraExtInterface, SetInvalidReflectedTemperature)
{
  float fReflectedTemperature(0.0f);
  ASSERT_NO_THROW(fReflectedTemperature = m_camera.getReflectedTemperature());
  std::cout << "Current reflected temperature: " << fReflectedTemperature << std::endl;

  ASSERT_THROW(m_camera.setReflectedTemperature(-300.0f), std::exception);
  ASSERT_THROW(m_camera.setReflectedTemperature(10000.0f), std::exception);

  float fChangedReflectedTemperature(0.0f);
  ASSERT_NO_THROW(fChangedReflectedTemperature = m_camera.getReflectedTemperature());
  EXPECT_NEAR(fReflectedTemperature, fChangedReflectedTemperature, 0.01);
  std::cout << "reflected temperature still: " << fChangedReflectedTemperature << std::endl;
}


TEST_F(CameraExtInterface, GetIrImage)
{
  cv::Mat matImageIr;
  ASSERT_NO_THROW(matImageIr = m_camera.captureIr());

  EXPECT_GE(matImageIr.rows, 100);
  EXPECT_GE(matImageIr.cols, 100);

  float fVal = matImageIr.at<float>(10, 10);
  std::cout << "one value (10:10) = " << fVal << std::endl;

  EXPECT_LE(-100.0f, fVal);
  EXPECT_GE(200.0f, fVal);
}

TEST_F(CameraExtInterface, Get100IrImage)
{
  for (uint32_t u32 = 0; u32 < 100; u32++)
  {
    cv::Mat matImageIr;
    ASSERT_NO_THROW(matImageIr = m_camera.captureIr());

    EXPECT_GE(matImageIr.rows, 100);
    EXPECT_GE(matImageIr.cols, 100);
    showIrOutput(matImageIr);
  }
}

// using testo pallette functions to get a colorized ir image
TEST_F(CameraExtInterface, Pallette100IrImage)
{
  for (uint32_t u32 = 0; u32 < 100; u32++)
  {
    cv::Mat matImageIr;
    ASSERT_NO_THROW(matImageIr = m_camera.captureIr());

    EXPECT_GE(matImageIr.rows, 100);
    EXPECT_GE(matImageIr.cols, 100);

    cv::Mat matColorImage;
    ASSERT_NO_THROW(matColorImage = Palette::map(matImageIr, PaletteType::PaletteTypeIron));
    showRgbOutput(matColorImage);
  }
}

TEST_F(CameraExtInterface, GetIrImageAndStopStream)
{
  cv::Mat matImageIr;
  ASSERT_NO_THROW(matImageIr = m_camera.captureIr());
  showIrOutput(matImageIr);
  ASSERT_NO_THROW(m_camera.stopIr());

  ASSERT_NO_THROW(matImageIr = m_camera.captureIr());
  showIrOutput(matImageIr);
  ASSERT_NO_THROW(m_camera.stopIr());
}


TEST_F(CameraExtInterface, GetVisImage)
{
  cv::Mat_<cv::Vec<unsigned char, 3>> matImageRgb;
  ASSERT_NO_THROW(matImageRgb = m_camera.captureVis());

  EXPECT_GE(matImageRgb.rows, 100);
  EXPECT_GE(matImageRgb.cols, 100);
  cv::imshow("VisImage", matImageRgb);
  cv::waitKey(1000);
}

TEST_F(CameraExtInterface, GetVisImageAndStopStream)
{
  cv::Mat matImageRgb;
  ASSERT_NO_THROW(matImageRgb = m_camera.captureVis());
  cv::imshow("Image", matImageRgb);
  cv::waitKey(1);
  ASSERT_NO_THROW(m_camera.stopVis());

  ASSERT_NO_THROW(matImageRgb = m_camera.captureVis());
  cv::imshow("Image", matImageRgb);
  cv::waitKey(1);
  ASSERT_NO_THROW(m_camera.stopVis());
}



int main(int argc, char *argv[])
{
  ::testing::InitGoogleTest(&argc, argv);
  int res = RUN_ALL_TESTS();
  return	res;
}