#!/bin/sh

cd ${STEAMAPPDIR}/Headless
exec mono Resonite.exe -HeadlessConfig /Config/Config.json -l /Logs
