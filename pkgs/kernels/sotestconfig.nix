{
  enableParallelBuilding = true;

  # Enable serial config options to make ttyS<n> device names stable
  # compared to Ubuntu/Fedora. Also disable some useless options to
  # save build time.
  extraConfig = ''
    SERIAL_8250 y
    SERIAL_8250_CONSOLE y
    SERIAL_8250_EXTENDED y
    SERIAL_8250_MANY_PORTS y
    SERIAL_8250_RUNTIME_UARTS 32
    SERIAL_8250_LPSS y
    SERIAL_8250_PCI y
    INTEL_MEI y
    INTEL_MEI_ME y
    LPC_ICH y
    LPC_SCH y
    MFD_INTEL_LPSS y
    MFD_INTEL_LPSS_PCI y
    MFD_INTEL_LPSS_ACPI y
  '';
}
