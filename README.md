# emacs-home

[![Marmalade](https://img.shields.io/badge/marmalade-available-8A2A8B.svg)](https://marmalade-repo.org/packages/emacs-home)  
[![License](https://img.shields.io/badge/LICENSE-GPL%20v3.0-blue.svg)](https://www.gnu.org/licenses/gpl.html)
[![Gratipay](http://img.shields.io/gratipay/myTerminal.svg)](https://gratipay.com/myTerminal)

A home-screen for Emacs

*emacs-home* can be used to display a few widgets on a 'home-screen', which can be summoned on the press of a key-binding.

## Installation

### Manual

Save the file *emacs-home.el* to disk and add the directory containing it to `load-path` using a command in your *.emacs* file like:

    (add-to-list 'load-path "~/.emacs.d/")

The above line assumes that you've placed the file into the Emacs directory '.emacs.d'.

Start the package with:

    (require 'emacs-home)

### Marmalade

If you have Marmalade added as a repository to your Emacs, you can just install *emacs-home* with

    M-x package-install emacs-home RET

## Usage

Currently *emacs-home* supports the following widgets:

1. Date and Time
2. Work-day progress
3. Pinned files
4. Pinned functions

Set a key-binding to open the configuration menu that displays all configured configurations.

    (global-set-key (kbd "C-;") 'emacs-home-show)

By default, only the date-time widget is shown. One needs to set a few variables to see rest of the widgets.

To see the work-day progress widget, set the day start and end times. These need to be set with numeric values in the format *hhmm*. Refer the below example.

    (emacs-home-set-day-start-time
        0800)
    (emacs-home-set-day-end-time
        1700)

If the current time is between the above two times, a progress-bar is shown.

To see the pinned files widget, use a snippet as shown below.

    (emacs-home-set-pinned-files (list '("t" "~/to-do.org")
                                       '("i" "~/Documents/work.md")))

To see the pinned functions widget, use a snippet as shown below.

    (emacs-home-set-pinned-functions (list '("s" snake)
                                           '("c" calc)))

While on the home-screen, pressing `g` updates it and `q` closes it.
Currently, as the entire screen is redrawn every second to update time, you would not need to manually update it. Once I implement partial updates, this may not be the case anymore.

I'm working to optimize screen redraw and bring more widgets to *emacs-home*. Feel free to share your feedback.
