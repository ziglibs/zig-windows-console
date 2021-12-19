pub const windows = @import("std").os.windows;

// General
pub const KEY_EVENT = 0x0001;
pub const MOUSE_EVENT = 0x0002;
pub const WINDOW_BUFFER_SIZE_EVENT = 0x0004;
pub const MENU_EVENT = 0x0008;
pub const FOCUS_EVENT = 0x0010;

pub extern fn GetConsoleOutputCP() c_uint;
pub extern fn SetConsoleOutputCP(wCodePageID: c_uint) windows.BOOL;

pub extern fn SetConsoleMode(hConsoleHandle: windows.HANDLE, dwMode: windows.DWORD) windows.BOOL;
pub extern fn GetConsoleMode(hConsoleHandle: windows.HANDLE, lpMode: *windows.DWORD) windows.BOOL;
pub extern fn WriteConsoleW(
    hConsoleOutput: windows.HANDLE,
    lpBuffer: [*]const u16,
    nNumberOfCharsToWrite: windows.DWORD,
    lpNumberOfCharsWritten: ?*windows.DWORD,
    lpReserved: ?*c_void,
) windows.BOOL;

// Events
const union_unnamed_248 = extern union {
    UnicodeChar: windows.WCHAR,
    AsciiChar: windows.CHAR,
};
pub const KEY_EVENT_RECORD = extern struct {
    bKeyDown: windows.BOOL,
    wRepeatCount: windows.WORD,
    wVirtualKeyCode: windows.WORD,
    wVirtualScanCode: windows.WORD,
    uChar: union_unnamed_248,
    dwControlKeyState: windows.DWORD,
};
pub const PKEY_EVENT_RECORD = *KEY_EVENT_RECORD;

pub const MOUSE_EVENT_RECORD = extern struct {
    dwMousePosition: windows.COORD,
    dwButtonState: windows.DWORD,
    dwControlKeyState: windows.DWORD,
    dwEventFlags: windows.DWORD,
};
pub const PMOUSE_EVENT_RECORD = *MOUSE_EVENT_RECORD;

pub const WINDOW_BUFFER_SIZE_RECORD = extern struct {
    dwSize: windows.COORD,
};
pub const PWINDOW_BUFFER_SIZE_RECORD = *WINDOW_BUFFER_SIZE_RECORD;

pub const MENU_EVENT_RECORD = extern struct {
    dwCommandId: windows.UINT,
};
pub const PMENU_EVENT_RECORD = *MENU_EVENT_RECORD;

pub const FOCUS_EVENT_RECORD = extern struct {
    bSetFocus: windows.BOOL,
};
pub const PFOCUS_EVENT_RECORD = *FOCUS_EVENT_RECORD;

const union_unnamed_249 = extern union {
    KeyEvent: KEY_EVENT_RECORD,
    MouseEvent: MOUSE_EVENT_RECORD,
    WindowBufferSizeEvent: WINDOW_BUFFER_SIZE_RECORD,
    MenuEvent: MENU_EVENT_RECORD,
    FocusEvent: FOCUS_EVENT_RECORD,
};
pub const INPUT_RECORD = extern struct {
    EventType: windows.WORD,
    Event: union_unnamed_249,
};
pub const PINPUT_RECORD = *INPUT_RECORD;

pub extern "kernel32" fn ReadConsoleInputW(
    hConsoleInput: windows.HANDLE,
    lpBuffer: PINPUT_RECORD,
    nLength: windows.DWORD,
    lpNumberOfEventsRead: *windows.DWORD,
) windows.BOOL;
