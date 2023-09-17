shift_down  <- false
editor_open <- false
program <- {}
pointer <- 0

text <- ppmod.text("!!", -1, -0.2)
text.SetSize(5)

update_text <- function () {
    local string = ""
    for (local i = pointer - 10; i < pointer; i++) {
        if (i >= 0 && i <= program.len()) {string += " " + program[i]} else {string += "   "}
    }
    for (local i = pointer; i < pointer + 10; i++) {
        if ( i >= program.len()) {string += " _ "} else {string += " " + program[i]}
    }
    string += "\n^"
    text.SetText(string)
    text.Display(99999)
}

compile_brainf <- function (program, alloc = 255) {
    local memory = {}
    local stack = []
    local output = ""
    local ptr = 0

    for (local i = 0; i < alloc; i++) {
        memory[i] <- 0
    }

    for (local i = 0; i < program.len(); i++) {
        switch (program[i]) {
            case '>':
                ptr++
                break
            case '<':
                ptr--
                break
            case '+':
                memory[ptr]++
                if (memory[ptr] > 255) {
                    memory[ptr] = 0
                }
                break
            case '-':
                memory[ptr]--
                if (memory[ptr] < 0) {
                    memory[ptr] = 255
                }
                break
            case '.':
                output += format("%c", memory[ptr])
                break
            case ',':
                break
            case '[':
                if (memory[ptr] == 0) {
                    local depth = 1
                    while (depth > 0) {
                        i++
                        if (program[i] == '[') depth++
                        if (program[i] == ']') depth--
                    }
                } else {
                    stack.push(i)
                }
                break
            case ']':
                if (memory[ptr] != 0) {
                    i = stack.pop() - 1
                }
                break
        }
    }
    return output, memory
}

insert_period <- function () {
    if (shift_down) {
        program[pointer] <- ">"
    } else {
        program[pointer] <- "."
    }
    update_text()
}

insert_comma <- function () {
    if (shift_down) {
        program[pointer] <- "<"
    } else {
        program[pointer] <- ","
    }
    update_text()
}

insert_equals <- function () {
    if (shift_down) {
        program[pointer] <- "+"
        update_text()
    }
}

insert_dash <- function () {
    if (!shift_down) {
        program[pointer] <- "-"
        update_text()
    }
}

insert_lbracket <- function () {
    if (!shift_down) {
        program[pointer] <- "["
        update_text()
    }
}

insert_rbracket <- function () {
    if (!shift_down) {
        program[pointer] <- "]"
        update_text()
    }
}

kill <- function () {
    if (pointer < program.len()) delete program[pointer]
    update_text()
}

left <- function () {
    pointer--
    if (pointer < 0) pointer = 0
    update_text()
}

right <- function () {
    pointer++
    if (pointer > program.len()) pointer = pointer - 1
    update_text()
}

run <- function () {
    local str = ""
    foreach (i, value in program) {
        str += value
    }

    printl(str)
    printl(compile_brainf(str))
}

toggle_editor <- function () {
    editor_open <- !editor_open
    if (editor_open) {
        text.Display(999999)
        update_text()
    } else {
        text.Display(0)
    }
}

set_binds <- function () {
    SendToConsole("bind shift      \"script if (editor_open) shift_down <- !shift_down\"  ")
    SendToConsole("bind .          \"script if (editor_open) insert_period()\"            ")
    SendToConsole("bind ,          \"script if (editor_open) insert_comma()\"             ")
    SendToConsole("bind =          \"script if (editor_open) insert_equals()\"            ")
    SendToConsole("bind -          \"script if (editor_open) insert_dash()\"              ")
    SendToConsole("bind [          \"script if (editor_open) insert_lbracket()\"          ")
    SendToConsole("bind ]          \"script if (editor_open) insert_rbracket()\"          ")
    SendToConsole("bind rightarrow \"script if (editor_open) right()\"                    ")
    SendToConsole("bind leftarrow  \"script if (editor_open) left()\"                     ")
    SendToConsole("bind enter      \"script if (editor_open) run()\"                      ")
    SendToConsole("bind backspace  \"script if (editor_open) kill()\"                     ")
    SendToConsole("bind j          \"script toggle_editor()\"                             ")
}

set_binds()