import { type Build } from 'xbuild';

const build: Build = {
    common: {
        project: 'tinycthread',
        archs: ['x64'],
        variables: [],
        copy: {},
        defines: [],
        options: [
            ['TINYCTHREAD_DISABLE_TESTS', true],
            ['TINYCTHREAD_INSTALL', false]
        ],
        subdirectories: ['tinycthread'],
        libraries: {
            tinycthread: {}
        },
        buildDir: 'build',
        buildOutDir: '../libs',
        buildFlags: []
    },
    platforms: {
        win32: {
            windows: {},
            android: {
                archs: ['x86', 'x86_64', 'armeabi-v7a', 'arm64-v8a'],
            }
        },
        linux: {
            linux: {}
        },
        darwin: {
            macos: {}
        }
    }
}

export default build;