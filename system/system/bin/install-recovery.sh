#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/bootdevice/by-name/recovery:134217728:5e5c956c2d1bb3095b8f71206eec8fa4dd702c54; then
  applypatch  \
          --patch /system/recovery-from-boot.p \
          --source EMMC:/dev/block/bootdevice/by-name/boot:134217728:824d88623da8609c66df4e348a96b668a0be91a2 \
          --target EMMC:/dev/block/bootdevice/by-name/recovery:134217728:5e5c956c2d1bb3095b8f71206eec8fa4dd702c54 && \
      log -t recovery "Installing new recovery image: succeeded" && \
        echo "Installing new recovery image: succeeded" > /cache/recovery/last_install_recovery_status || \
      (log -t recovery "Installing new recovery image: failed" && \
        echo "Installing new recovery image: failed" > /cache/recovery/last_install_recovery_status)
else
  log -t recovery "Recovery image already installed" && \
  echo "Recovery image already installed" > /cache/recovery/last_install_recovery_status
fi
