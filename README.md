# Vega Virtual Device (VVD) Docker

A Dockerized solution for running Amazon's Vega Virtual Device (Vega SDK) with Appium automation support. This project provides a complete containerized environment for testing and automating applications on Amazon's virtual device platform.

## 🚀 Features

- **Complete Vega SDK Installation**: Automated installation of the `Vega SDK` and all required dependencies
- **Virtual Device Simulator**: Run Amazon's `Vega Virtual device` simulator in a containerized environment
- **Appium Integration**: Pre-configured `Appium Server` (v2.2.2) with `Amazon Vega Appium Driver` for automation testing
- **Automated Workflow**: Automatic simulator startup, app installation, and Appium server initialization
- **GUI Support**: Web-based interface via `Selkies` for remote access
- **KVM Acceleration**: Hardware acceleration support for better performance

## 📋 Prerequisites

- **Docker**
- **Docker Compose**
- **Linux host** with KVM support (for hardware acceleration)
- **Vega SDK Credentials**: You'll need the following information from [Amazon's Vega SDK documentation](https://developer.amazon.com/docs/vega/0.21/install-vega-sdk.html#ubuntu):
  - SDK Version
  - Installer Script URL
  - SDK Download URL
  - Simulator Download URL
  - Directed ID

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/prmiguel/vega-virtual-device-selkies.git
cd vega-virtual-device-selkies
```

### 2. Configure Environment Variables

Create a `.env` file in the project root (or export the variables in your shell):

```bash
export SDK_VERSION=<your-sdk-version>
export INSTALLER_SCRIPT=<installer-script-url>
export SDK_URL=<sdk-download-url>
export SIM_URL=<simulator-download-url>
export DIRECTED_ID=<your-directed-id>
```

**Note**: Get these values from the [Amazon Vega SDK installation guide](https://developer.amazon.com/docs/vega/0.21/install-vega-sdk.html#ubuntu).

### 3. Build the Docker Image

```bash
docker compose build
```

This will:
- Install all system dependencies (QEMU, libvirt, bridge-utils, etc.)
- Download and install the Vega SDK
- Install Appium and the Amazon Vega driver
- Configure the runtime environment

**Build Time**: The initial build may take 10-20 minutes depending on your internet connection, as it downloads the SDK and all dependencies.

## 🎯 Usage

### Start the Container

```bash
docker compose up -d
```

The container will automatically:
1. Start the Vega virtual device simulator
2. Wait for the simulator to be ready
3. Enable the automation toolkit service
4. Start the Appium server on port 4723
5. Install and launch your application (if configured)

### View Logs

```bash
docker compose logs -f vvd
```

### Stop the Container

```bash
docker compose down
```

### Stop and Remove Volumes

```bash
docker compose down -v
```

## ⚙️ Configuration

### Environment Variables

The following environment variables can be configured in `compose.yml`:

| Variable | Description | Default |
|----------|-------------|---------|
| `PACKAGE_PATH` | Path to your `.vpkg` file inside the container | `/apps/keplervideoapp_x86_64.vpkg` |
| `APP_NAME` | Package name of the app to launch | `com.amazondeveloper.keplervideoapp.main` |
| `TZ` | Timezone | `Etc/UTC` |

### Volume Mounts

The default configuration mounts your app builds directory:

```yaml
volumes:
  - $HOME/workspace/apps/build/x86_64-debug:/apps
```

Modify this path in `compose.yml` to point to your application build directory.

### Ports

The following ports are exposed:

- **3000**: Selkies web UI (if enabled)
- **3001**: Additional Selkies service port
- **4723**: Appium server endpoint

### Network Mode

The container runs in `host` network mode for optimal performance and to allow direct access to the virtual device.

## 🏗️ Architecture

### Dockerfile Stages

1. **Dependencies Stage**: Installs system dependencies (QEMU, libvirt, Python 3.8, etc.)
2. **SDK Stage**: Downloads and installs the Vega SDK using the official installer script
3. **Final Stage**: Sets up the runtime environment with Appium and automation tools

### Startup Process

The `wrapped-vvd` script orchestrates the following sequence:

1. **Simulator Startup**: Starts the Vega virtual device simulator
2. **Connection Wait**: Waits for the simulator to be fully connected
3. **Popup Handling**: Closes any emulator popup dialogs
4. **Automation Toolkit**: Enables the automation toolkit service
5. **App Management**: Uninstalls the default launcher app
6. **Window Management**: Resizes the virtual device window
7. **Appium Server**: Starts the Appium server on port 4723
8. **App Installation**: Installs your application package
9. **App Launch**: Launches your application

## 🔌 Appium Integration

The container includes a pre-configured Appium server with:

- **Appium Version**: 2.2.2
- **Vega Driver**: `@amazon-devices/appium-kepler-driver@3.30.0`
- **Selenium WebDriver**: Pre-installed for test automation

### Connecting to Appium

Once the container is running, you can connect to Appium at:

```
http://localhost:4723
```

### Example Test Connection

```java
import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import java.net.URL;

UiAutomator2Options options = new UiAutomator2Options();
options.setPlatformName("Kepler");
options.setDeviceName("Simulator");
options.setAppPackage("com.amazondeveloper.keplervideoapp.main");

AppiumDriver driver = new AppiumDriver(
    new URL("http://localhost:4723"), 
    options
);
```

## 🐛 Troubleshooting

### KVM Not Available

If you see KVM-related errors, ensure:

1. Your system supports virtualization:
   ```bash
   grep -E 'vmx|svm' /proc/cpuinfo
   ```

2. KVM module is loaded:
   ```bash
   lsmod | grep kvm
   ```

3. `/dev/kvm` has proper permissions:
   ```bash
   ls -l /dev/kvm
   ```

### Simulator Not Starting

- Check container logs: `docker compose logs vvd`
- Ensure sufficient resources (CPU, memory, disk space)
- Verify SDK installation completed successfully

### Appium Connection Issues

- Verify Appium is running: Check logs for "Appium server started"
- Ensure port 4723 is not blocked by firewall
- Check network mode is set to `host` in `compose.yml`

### Build Failures

- Verify all environment variables are set correctly
- Check internet connectivity (SDK download requires stable connection)
- Ensure Docker has sufficient disk space (build requires ~5-10GB)

## 🎬 Demo

<!-- TODO: Add demo section with screenshots, videos, or example usage -->

### Quick Start Demo

1. **Start the container**:
   ```bash
   docker compose up -d
   ```

2. **Verify Appium is running**:
   ```bash
   curl http://localhost:4723/status
   ```

4. **Access the web UI** (if enabled):
   ```
   http://localhost:3000
   ```

### Example Automation Test

```java
// ExampleTest.java
import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import java.net.URL;
import java.time.Duration;

public class ExampleTest {
    
    public static void testVegaApp() throws Exception {
        UiAutomator2Options options = new UiAutomator2Options();
        options.setPlatformName("Kepler");
        options.setDeviceName("Simulator");
        options.setAppPackage("com.amazondeveloper.keplervideoapp.main");
        
        AppiumDriver driver = new AppiumDriver(
            new URL("http://localhost:4723"), 
            options
        );
        
        try {
            // Your test code here
            Thread.sleep(5000); // Wait for app to load
            System.out.println("App launched successfully!");
        } finally {
            driver.quit();
        }
    }
    
    public static void main(String[] args) throws Exception {
        testVegaApp();
    }
}
```

**Maven Dependencies** (add to `pom.xml`):

```xml
<dependencies>
    <dependency>
        <groupId>io.appium</groupId>
        <artifactId>java-client</artifactId>
        <version>9.0.0</version>
    </dependency>
    <dependency>
        <groupId>org.seleniumhq.selenium</groupId>
        <artifactId>selenium-java</artifactId>
        <version>4.15.0</version>
    </dependency>
</dependencies>
```

Run the test:
```bash
javac ExampleTest.java
java ExampleTest
```

Or with Maven:
```bash
mvn test
```

## 📚 Additional Resources

- [Amazon Vega SDK Documentation](https://developer.amazon.com/docs/vega/0.21/install-vega-sdk.html)
- [Appium Documentation](https://appium.io/docs/en/latest/)
- [Appium for Vega Integration Documentation](https://developer.amazon.com/docs/vega/0.21/appium-install.html)

## 🙏 Acknowledgments

- Amazon for the Vega Virtual Device SDK
- The Appium project for automation framework support
- LinuxServer.io for the base container image
