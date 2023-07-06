package org.wiremock.docker.it.samples;

import org.testcontainers.junit.jupiter.Container;
import org.wiremock.docker.it.TestConfig;
import org.wiremock.integrations.testcontainers.WireMockContainer;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.FileVisitOption;
import java.nio.file.Files;
import java.nio.file.Path;

public abstract class AbtsractSampleTest {

  @Container
  public WireMockContainer wiremockServer = createWireMockContainer();

  //TODO: Simplify API once WireMock container is amended
  public WireMockContainer createWireMockContainer() {
    final WireMockContainer wiremockServer = new WireMockContainer(TestConfig.WIREMOCK_IMAGE_TAG);

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
    if (Files.exists(mappingsDir) && Files.isDirectory(mappingsDir)) {
      Files.walk(mappingsDir, FileVisitOption.FOLLOW_LINKS).forEach(path -> {
        if (!Files.isRegularFile(path)) {
          return;
        }
        String flattenedFileName = path.toString().replace('/', '_');
        final String json;
        try {
            json = Files.readString(path);
        } catch (IOException ex) {
          throw new IllegalStateException("Failed to read configuration from " + path, ex);
        }
       // container.withMapping(flattenedFileName, json);
       // container.withCopyToContainer()
      });
    } else {
      throw new FileNotFoundException("Mappings directory does not exist: " + mappingsDir);
    }
  }

  public void forFilesDir(WireMockContainer container, Path filesDir) throws IOException {
    if (Files.exists(filesDir) && Files.isDirectory(filesDir)) {
      Files.walk(filesDir, FileVisitOption.FOLLOW_LINKS).forEach(path -> {
        if (Files.isRegularFile(path)) {
          String flattenedFileName = path.toString().replace('/', '_');
          container.withFile(flattenedFileName, path.toFile());
        }
      });
    } else {
      throw new FileNotFoundException("Mappings directory does not exist: " + filesDir);
    }
  }

  public abstract Path getHomeDir();

  public Path getMappingsDir() {
    return getHomeDir().resolve("stubs/mappings");
  }

  public Path getFilesDir() {
    return getHomeDir().resolve("stubs/__files");
  }
}
