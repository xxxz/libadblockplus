#include <AdblockPlus.h>
#include <gtest/gtest.h>

#include "../src/Utils.h"

namespace
{
  const std::string testPath = "libadblockplus-test-file";

  void WriteString(AdblockPlus::FileSystem& fileSystem,
                   const std::string& content)
  {
    std::tr1::shared_ptr<std::stringstream> input(new std::stringstream);
    *input << content;
    fileSystem.Write(testPath, input);
  }
}

TEST(DefaultFileSystemTest, WriteReadRemove)
{
  AdblockPlus::DefaultFileSystem fileSystem;
  WriteString(fileSystem, "foo");
  std::string output = AdblockPlus::Utils::Slurp(*fileSystem.Read(testPath));
  fileSystem.Remove(testPath);
  ASSERT_EQ("foo", output);
}

TEST(DefaultFileSystemTest, StatWorkingDirectory)
{
  AdblockPlus::DefaultFileSystem fileSystem;
  const AdblockPlus::FileSystem::StatResult result = fileSystem.Stat(".");
  ASSERT_TRUE(result.exists);
  ASSERT_TRUE(result.isDirectory);
  ASSERT_FALSE(result.isFile);
  ASSERT_NE(0, result.lastModified);
}

TEST(DefaultFileSystemTest, WriteMoveStatRemove)
{
  AdblockPlus::DefaultFileSystem fileSystem;
  WriteString(fileSystem, "foo");
  AdblockPlus::FileSystem::StatResult result = fileSystem.Stat(testPath);
  ASSERT_TRUE(result.exists);
  ASSERT_TRUE(result.isFile);
  ASSERT_FALSE(result.isDirectory);
  ASSERT_NE(0, result.lastModified);
  const std::string newTestPath = testPath + "-new";
  fileSystem.Move(testPath, newTestPath);
  result = fileSystem.Stat(testPath);
  ASSERT_FALSE(result.exists);
  result = fileSystem.Stat(newTestPath);
  ASSERT_TRUE(result.exists);
  fileSystem.Remove(newTestPath);
  result = fileSystem.Stat(newTestPath);
  ASSERT_FALSE(result.exists);
}