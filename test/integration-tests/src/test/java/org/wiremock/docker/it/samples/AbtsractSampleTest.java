package org.wiremock.docker.it.samples;

import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.utility.MountableFile;
import org.wiremock.docker.it.TestConfig;
import org.wiremock.integrations.testcontainers.WireMockContainer;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.FileVisitOption;
import java.nio.file.Files;
import java.nio.file.Path;

public abstract class AbtsractSampleTest {

  @Container
  public WireMockContainer wiremockServer = createWireMockContainer();

  private static final String MAPPINGS_DIR = "/home/wiremock/mappings/";
  private static final String FILES_DIR = "/home/wiremock/__files/";

  public WireMockContainer createWireMockContainer() {
    return createWireMockContainer(false);
  }

  //TODO: Simplify API once WireMock container is amended
  public WireMockContainer createWireMockContainer(boolean useHttps) {
    final WireMockContainer wiremockServer = useHttps
      ? new WireMockHttpsContainer(TestConfig.WIREMOCK_IMAGE)
      : new WireMockContainer(TestConfig.WIREMOCK_IMAGE);

    // TODO: Move to the WireMock Module
    try {
      forMappingsDir(wiremockServer, getMappingsDir());
      forFilesDir(wiremockServer, getFilesDir());
    } catch (IOException ex) {
      throw new AssertionError("Failed to read the home directory", ex);
    }
    return wiremockServer;
  }

  public void forMappingsDir(WireMockContainer container, Path mappingsDir) throws IOException {
    final Path targetMappingDir = new File(MAPPINGS_DIR).toPath();

    if (Files.exists(mappingsDir) && Files.isDirectory(mappingsDir)) {
      Files.walk(mappingsDir, FileVisitOption.FOLLOW_LINKS).forEach(path -> {
        if (!Files.isRegularFile(path)) {
          return;
        }
        container.withCopyToContainer(MountableFile.forHostPath(path),
          targetMappingDir.resolve(mappingsDir.relativize(path)).toString());
      });
    } else {
      throw new FileNotFoundException("Mappings directory does not exist: " + mappingsDir);
    }
  }

  public void forFilesDir(WireMockContainer container, Path filesDir) throws IOException {
    final Path targetFilesDir = new File(FILES_DIR).toPath();
    if (Files.exists(filesDir) && Files.isDirectory(filesDir)) {
      Files.walk(filesDir, FileVisitOption.FOLLOW_LINKS).forEach(path -> {
        if (Files.isRegularFile(path)) {
          container.withCopyToContainer(MountableFile.forHostPath(path),
            targetFilesDir.resolve(filesDir.relativize(path)).toString());
        }
      });
    } else {
      throw new FileNotFoundException("Files directory does not exist: " + filesDir);
    }
  }

  public abstract Path getHomeDir();

  public Path getMappingsDir() {
    return getHomeDir().resolve("stubs/mappings");
  }

  public Path getFilesDir() {
    return getHomeDir().resolve("stubs/__files");
  }

  public static class WireMockHttpsContainer extends WireMockContainer {

    public WireMockHttpsContainer(String tag) {
      super(tag);
    }

    @Override
    protected void configure() {
      super.configure();
      withExposedPorts(8080, 8443);
    }
  }
}
