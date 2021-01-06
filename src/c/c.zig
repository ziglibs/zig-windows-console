pub usingnamespace @import("std").os.windows;

// General
pub const KEY_EVENT = 0x0001;
pub const MOUSE_EVENT = 0x0002;
pub const WINDOW_BUFFER_SIZE_EVENT = 0x0004;
pub const MENU_EVENT = 0x0008;
pub const FOCUS_EVENT = 0x0010;

pub extern fn SetConsoleMode(hConsoleHandle: HANDLE, dwMode: DWORD) BOOL;
pub extern fn GetConsoleMode(hConsoleHandle: HANDLE, lpMode: LPDWORD) BOOL;

// Events
const union_unnamed_248 = extern union {
    UnicodeChar: WCHAR,
    AsciiChar: CHAR,
};
pub const KEY_EVENT_RECORD = extern struct {
    bKeyDown: BOOL,
    wRepeatCount: WORD,
    wVirtualKeyCode: WORD,
    wVirtualScanCode: WORD,
    uChar: union_unnamed_248,
    dwControlKeyState: DWORD,
};
pub const PKEY_EVENT_RECORD = *KEY_EVENT_RECORD;

pub const MOUSE_EVENT_RECORD = extern struct {
    dwMousePosition: COORD,
    dwButtonState: DWORD,
    dwControlKeyState: DWORD,
    dwEventFlags: DWORD,
};
pub const PMOUSE_EVENT_RECORD = *MOUSE_EVENT_RECORD;

pub const WINDOW_BUFFER_SIZE_RECORD = extern struct {
    dwSize: COORD,
};
pub const PWINDOW_BUFFER_SIZE_RECORD = *WINDOW_BUFFER_SIZE_RECORD;

pub const MENU_EVENT_RECORD = extern struct {
    dwCommandId: UINT,
};
pub const PMENU_EVENT_RECORD = *MENU_EVENT_RECORD;

pub const FOCUS_EVENT_RECORD = extern struct {
    bSetFocus: BOOL,
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
    EventType: WORD,
    Event: union_unnamed_249,
};
pub const PINPUT_RECORD = *INPUT_RECORD;

pub extern "kernel32" fn ReadConsoleInputW(
    hConsoleInput: HANDLE,
    lpBuffer: PINPUT_RECORD,
    nLength: DWORD,
    lpNumberOfEventsRead: LPDWORD
) BOOL;
