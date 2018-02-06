From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Tue, 06 Feb 2018 00:34:40 +0000
Subject: [PATCH 00/14] Add Kconfig unit tests
Message-Id: <1517877294-4826-1-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Ulf Magnusson <ulfalizer@gmail.com>, Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Linus Torvalds <torvalds@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Heinrich Schuchardt <xypron.glpk@gmx.de>, Yaakov Selkowitz <yselkowi@redhat.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Marc Herbert <marc.herbert@intel.com>

I am applying various patches to Kconfig these days.

However, I fear regressions.  I have been thinking of unit-tests.

There are various cryptic parts in Kconfig and corner cases where
it is difficult to notice breakage.  If unit-tests cover those,
I will be able to apply changes more confidently.

So, here is the trial.

After fixing some problems, I will add a basic test framework.
This is based on pytest.  Also, this is written in Python 3.
Python 2 will return in 2020.  So, I believe new python tools should be
written in Python 3.

This is my Python 3 and pytest versions.

$ python3 --version
Python 3.5.2
$ python3 -m pytest --version
This is pytest version 3.4.0, imported from /home/masahiro/.local/lib/python3.5/site-packages/pytest.py

If I use old pytest version, some parts did not work as expected.
If this does not work for you, please consider using newer pytest.

I will brush up the code more and add more test cases to do a better job.
Before proceeding more, I'd like to get consensus for this approach.
If you have an idea for better implementation, comments are appreciated.

How to use?
-----------

Please make sure Python3 and pytest for Python3 is installed on your system.

Then, run "make testconfig"

The result looks like as follows:

masahiro@grover:~/workspace/linux-yamada$ make testconfig
  HOSTCC  scripts/kconfig/conf.o
  HOSTCC  scripts/kconfig/zconf.tab.o
  HOSTLD  scripts/kconfig/conf
python3 -B -m pytest ./scripts/kconfig/tests \
-o cache_dir=/home/masahiro/workspace/linux-yamada/scripts/kconfig/tests/.cache \

========================== test session starts ==========================platform linux -- Python 3.5.2, pytest-3.3.2, py-1.5.2, pluggy-0.6.0 -- /usr/bin/python3
cachedir: scripts/kconfig/tests/.cache
rootdir: /home/masahiro/workspace/linux-yamada/scripts/kconfig/tests, inifile: pytest.ini
collected 12 items

scripts/kconfig/tests/auto_submenu_creation/__init__.py::test PASSED                                                   [  8%]
scripts/kconfig/tests/choice/__init__.py::test_oldask0 PASSED                                                          [ 16%]
scripts/kconfig/tests/choice/__init__.py::test_oldask1 PASSED                                                          [ 25%]
scripts/kconfig/tests/choice/__init__.py::test_allyes PASSED                                                           [ 33%]
scripts/kconfig/tests/choice/__init__.py::test_allmod PASSED                                                           [ 41%]
scripts/kconfig/tests/choice/__init__.py::test_allno PASSED                                                            [ 50%]
scripts/kconfig/tests/choice/__init__.py::test_alldef PASSED                                                           [ 58%]
scripts/kconfig/tests/choice_value_with_m_dep/__init__.py::test PASSED                                                 [ 66%]
scripts/kconfig/tests/err_recursive_inc/__init__.py::test PASSED                                                       [ 75%]
scripts/kconfig/tests/new_choice_with_dep/__init__.py::test PASSED                                                     [ 83%]
scripts/kconfig/tests/no_write_if_dep_unmet/__init__.py::test PASSED                                                   [ 91%]
scripts/kconfig/tests/warn_recursive_dep/__init__.py::test PASSED                                                      [100%]

========================= 12 passed in 0.08 seconds =========================



Masahiro Yamada (14):
  kconfig: send error messages to stderr
  kconfig: do not write choice values when their dependency becomes n
  kconfig: show '?' prompt even if no help text is available
  kconfig: print additional new line for choice for redirection
  kconfig: remove 'config*' pattern from .gitignnore
  kbuild: define PYTHON2 and PYTHON3 variables instead of PYTHON
  kconfig: test: add framework for Kconfig unit-tests
  kconfig: test: add basic 'choice' tests
  kconfig: test: test automatic submenu creation
  kconfig: test: check if new symbols in choice are asked
  kconfig: test: check .config sanity for choice values with unmet dep
  kconfig: test: check visibility of tristate choice values in y choice
  kconfig: test: check if recursive dependencies are detected
  kconfig: test: check if recursive inclusion is detected

 Makefile                                           |   5 +-
 arch/ia64/Makefile                                 |   2 +-
 scripts/kconfig/.gitignore                         |   1 -
 scripts/kconfig/Makefile                           |   8 +
 scripts/kconfig/conf.c                             |  29 +--
 scripts/kconfig/symbol.c                           |   4 +-
 .../kconfig/tests/auto_submenu_creation/Kconfig    |  50 ++++
 .../tests/auto_submenu_creation/__init__.py        |  12 +
 .../tests/auto_submenu_creation/expected_stdout    |  10 +
 scripts/kconfig/tests/choice/Kconfig               |  54 +++++
 scripts/kconfig/tests/choice/__init__.py           |  37 +++
 .../kconfig/tests/choice/alldef_expected_config    |   5 +
 .../kconfig/tests/choice/allmod_expected_config    |   9 +
 scripts/kconfig/tests/choice/allno_expected_config |   5 +
 .../kconfig/tests/choice/allyes_expected_config    |   9 +
 .../kconfig/tests/choice/oldask0_expected_stdout   |  10 +
 scripts/kconfig/tests/choice/oldask1_config        |   2 +
 .../kconfig/tests/choice/oldask1_expected_stdout   |  15 ++
 .../kconfig/tests/choice_value_with_m_dep/Kconfig  |  20 ++
 .../tests/choice_value_with_m_dep/__init__.py      |  15 ++
 .../kconfig/tests/choice_value_with_m_dep/config   |   2 +
 .../tests/choice_value_with_m_dep/expected_config  |   3 +
 .../tests/choice_value_with_m_dep/expected_stdout  |   4 +
 scripts/kconfig/tests/conftest.py                  | 255 +++++++++++++++++++++
 scripts/kconfig/tests/err_recursive_inc/Kconfig    |   1 +
 .../kconfig/tests/err_recursive_inc/Kconfig.inc    |   1 +
 .../kconfig/tests/err_recursive_inc/__init__.py    |  10 +
 .../tests/err_recursive_inc/expected_stderr        |   4 +
 scripts/kconfig/tests/new_choice_with_dep/Kconfig  |  37 +++
 .../kconfig/tests/new_choice_with_dep/__init__.py  |  14 ++
 scripts/kconfig/tests/new_choice_with_dep/config   |   3 +
 .../tests/new_choice_with_dep/expected_stdout      |  10 +
 .../kconfig/tests/no_write_if_dep_unmet/Kconfig    |  14 ++
 .../tests/no_write_if_dep_unmet/__init__.py        |  17 ++
 scripts/kconfig/tests/no_write_if_dep_unmet/config |   1 +
 .../tests/no_write_if_dep_unmet/expected_config    |   5 +
 scripts/kconfig/tests/pytest.ini                   |   6 +
 scripts/kconfig/tests/warn_recursive_dep/Kconfig   |  62 +++++
 .../kconfig/tests/warn_recursive_dep/__init__.py   |  10 +
 .../tests/warn_recursive_dep/expected_stderr       |  33 +++
 scripts/kconfig/zconf.l                            |  27 ++-
 41 files changed, 789 insertions(+), 32 deletions(-)
 create mode 100644 scripts/kconfig/tests/auto_submenu_creation/Kconfig
 create mode 100644 scripts/kconfig/tests/auto_submenu_creation/__init__.py
 create mode 100644 scripts/kconfig/tests/auto_submenu_creation/expected_stdout
 create mode 100644 scripts/kconfig/tests/choice/Kconfig
 create mode 100644 scripts/kconfig/tests/choice/__init__.py
 create mode 100644 scripts/kconfig/tests/choice/alldef_expected_config
 create mode 100644 scripts/kconfig/tests/choice/allmod_expected_config
 create mode 100644 scripts/kconfig/tests/choice/allno_expected_config
 create mode 100644 scripts/kconfig/tests/choice/allyes_expected_config
 create mode 100644 scripts/kconfig/tests/choice/oldask0_expected_stdout
 create mode 100644 scripts/kconfig/tests/choice/oldask1_config
 create mode 100644 scripts/kconfig/tests/choice/oldask1_expected_stdout
 create mode 100644 scripts/kconfig/tests/choice_value_with_m_dep/Kconfig
 create mode 100644 scripts/kconfig/tests/choice_value_with_m_dep/__init__.py
 create mode 100644 scripts/kconfig/tests/choice_value_with_m_dep/config
 create mode 100644 scripts/kconfig/tests/choice_value_with_m_dep/expected_config
 create mode 100644 scripts/kconfig/tests/choice_value_with_m_dep/expected_stdout
 create mode 100644 scripts/kconfig/tests/conftest.py
 create mode 100644 scripts/kconfig/tests/err_recursive_inc/Kconfig
 create mode 100644 scripts/kconfig/tests/err_recursive_inc/Kconfig.inc
 create mode 100644 scripts/kconfig/tests/err_recursive_inc/__init__.py
 create mode 100644 scripts/kconfig/tests/err_recursive_inc/expected_stderr
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/Kconfig
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/__init__.py
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/config
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/expected_stdout
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/Kconfig
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/__init__.py
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/config
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/expected_config
 create mode 100644 scripts/kconfig/tests/pytest.ini
 create mode 100644 scripts/kconfig/tests/warn_recursive_dep/Kconfig
 create mode 100644 scripts/kconfig/tests/warn_recursive_dep/__init__.py
 create mode 100644 scripts/kconfig/tests/warn_recursive_dep/expected_stderr

-- 
2.7.4

