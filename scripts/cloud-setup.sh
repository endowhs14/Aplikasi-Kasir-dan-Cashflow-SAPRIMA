#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$repo_root/scripts/cloud-env.sh"
mkdir -p /workspace/toolchains "$GRADLE_USER_HOME" "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
if [[ ! -d /workspace/toolchains/flutter/.git ]]; then
  git clone --depth 1 --branch 3.47.7 https://github.com/flutter/flutter.git /workspace/toolchains/flutter
fi
actual_flutter=$(git -C /workspace/toolchains/flutter rev-parse HEAD)
[[ "$actual_flutter" == abaf9c523780a608bd46686fd5e53740a07077f8 ]] || { echo 'Flutter pin differs; review existing toolchain.' >&2; exit 1; }
python3 - <<'PY'
import hashlib, os, pathlib, tarfile, urllib.parse, urllib.request, zipfile
root=pathlib.Path('/workspace/toolchains')
jdk=root/'jdk-21.0.12.1+1'
if not (jdk/'bin/javac').exists():
    url='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1%2B1/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12.1_1.tar.gz'
    expected=urllib.request.urlopen(url+'.sha256.txt').read().decode().split()[0]
    archive=root/'jdk.tar.gz'; urllib.request.urlretrieve(url,archive)
    assert hashlib.sha256(archive.read_bytes()).hexdigest()==expected
    with tarfile.open(archive) as tar: tar.extractall(root,filter='data')
    archive.unlink()
cli=root/'android-sdk/cmdline-tools/latest'
if not (cli/'bin/sdkmanager').exists():
    archive=root/'android-tools.zip'
    urllib.request.urlretrieve('https://dl.google.com/android/repository/commandlinetools-linux-16111833_latest.zip',archive)
    assert hashlib.sha1(archive.read_bytes()).hexdigest()=='e025545c62a8e64c7559119566a569fb1dec5f60'
    cli.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(archive) as z: z.extractall(cli.parent)
    (cli.parent/'cmdline-tools').rename(cli)
    for p in (cli/'bin').iterdir(): p.chmod(0o755)
    archive.unlink()
# Runtime proxy addresses can change. Never copy credentials to the repository.
u=urllib.parse.urlsplit(os.environ.get('HTTPS_PROXY',''))
props=[]
if u.hostname:
    if u.username or u.password: raise RuntimeError('Use supported proxy credential injection; do not save secrets.')
    for scheme in ('http','https'):
        props += [f'systemProp.{scheme}.proxyHost={u.hostname}',f'systemProp.{scheme}.proxyPort={u.port or 80}']
    props += ['systemProp.http.nonProxyHosts=localhost|127.*']
trust=pathlib.Path('/etc/ssl/certs/java/cacerts')
if trust.exists(): props += [f'systemProp.javax.net.ssl.trustStore={trust}']
# Only this generated local file is owned by this setup script.
(root/'gradle/gradle.properties').write_text('\n'.join(props)+'\n')
PY
javac -version
flutter config --no-analytics --android-sdk "$ANDROID_HOME" --jdk-dir "$JAVA_HOME"
sdkmanager --sdk_root="$ANDROID_HOME" 'platform-tools' 'platforms;android-35' 'platforms;android-36' 'build-tools;36.0.0' 'ndk;28.2.13676358' 'cmake;3.22.1'
cd "$repo_root/apps/mobile"
flutter pub get --enforce-lockfile
