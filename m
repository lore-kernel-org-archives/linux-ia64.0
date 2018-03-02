From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 02 Mar 2018 04:31:50 +0000
Subject: [PATCH v2 00/11] Add Kconfig unit tests
Message-Id: <1519965121-12017-1-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Marek <michal.lkml@markovi.net>, Ulf Magnusson <ulfalizer@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>


I am applying various cleanups to Kconfig these days.

However, I fear regressions.  I have been thinking of unit-tests.

There are various cryptic parts in Kconfig and corner cases where
it is difficult to notice breakage.  If unit-tests cover those,
I will be able to apply changes more confidently.

This series introduces a unit-tests.  The framework is written based
on pytest.  Also, this is written in Python 3.  Python 2 will retire
in 2020.  So, I believe new python tools should be written in Python 3.

This is my Python 3 and pytest versions.

$ python3 --version
Python 3.5.2
$ python3 -m pytest --version
This is pytest version 3.4.1, imported from /home/masahiro/.local/lib/python3.5/site-packages/pytest.py

How to use?
-----------

Please make sure Python3 and pytest are installed on your system.

Then, run "make testconfig"

The result looks like as follows:

$ make testconfig
python3 -B -m pytest ./scripts/kconfig/tests \
-o cache_dir=/home/masahiro/workspace/bsp/linux-yamada/scripts/kconfig/tests/.cache \

================= test session starts ================platform linux -- Python 3.5.2, pytest-3.4.1, py-1.5.2, pluggy-0.6.0 -- /usr/bin/python3
cachedir: scripts/kconfig/tests/.cache
rootdir: /home/masahiro/workspace/bsp/linux-yamada/scripts/kconfig/tests, inifile: pytest.ini
collected 14 items

scripts/kconfig/tests/auto_submenu/__init__.py::test PASSED                     [  7%]
scripts/kconfig/tests/choice/__init__.py::test_oldask0 PASSED                   [ 14%]
scripts/kconfig/tests/choice/__init__.py::test_oldask1 PASSED                   [ 21%]
scripts/kconfig/tests/choice/__init__.py::test_allyes PASSED                    [ 28%]
scripts/kconfig/tests/choice/__init__.py::test_allmod PASSED                    [ 35%]
scripts/kconfig/tests/choice/__init__.py::test_allno PASSED                     [ 42%]
scripts/kconfig/tests/choice/__init__.py::test_alldef PASSED                    [ 50%]
scripts/kconfig/tests/choice_value_with_m_dep/__init__.py::test PASSED          [ 57%]
scripts/kconfig/tests/err_recursive_inc/__init__.py::test PASSED                [ 64%]
scripts/kconfig/tests/inter_choice/__init__.py::test PASSED                     [ 71%]
scripts/kconfig/tests/new_choice_with_dep/__init__.py::test PASSED              [ 78%]
scripts/kconfig/tests/no_write_if_dep_unmet/__init__.py::test PASSED            [ 85%]
scripts/kconfig/tests/rand_nested_choice/__init__.py::test PASSED               [ 92%]
scripts/kconfig/tests/warn_recursive_dep/__init__.py::test PASSED               [100%]


Changes in v2:
  - Add backward compatibility for PYTHON
  - Add 'randconfig' support
  - Add docstring
  - Fix various style errors detected by 'pep8' and 'pep257'
  - coding style clean-up based on PEP8, PEP257
  - shorten directory name  'auto_submenu_creation' -> 'auto_submenu'
  - coding style clean-up based on PEP8, PEP257
  - coding style clean-up based on PEP8, PEP257
  - coding style clean-up based on PEP8, PEP257
  - coding style clean-up based on PEP8, PEP257
  - Newly added
  - Newly added
  - Fix missing end quote
  - coding style clean-up based on PEP8, PEP257
  - coding style clean-up based on PEP8, PEP257

Masahiro Yamada (11):
  kbuild: define PYTHON2 and PYTHON3 variables instead of PYTHON
  kconfig: unittest: add framework for Kconfig unit testing
  kconfig: unittest: add basic 'choice' tests
  kconfig: unittest: test automatic submenu creation
  kconfig: unittest: test if new symbols in choice are asked
  kconfig: unittest: check unneeded "is not set" with unmet dependency
  kconfig: unittest: check visibility of tri-choice values in y choice
  kconfig: unittest: test defconfig when two choices interact
  kconfig: unittest: test randconfig for choice in choice
  kconfig: unittest: test if recursive dependencies are detected
  kconfig: unittest: test if recursive inclusion is detected

 Makefile                                           |   5 +-
 arch/ia64/Makefile                                 |   2 +-
 scripts/kconfig/Makefile                           |   8 +
 scripts/kconfig/tests/auto_submenu/Kconfig         |  50 ++++
 scripts/kconfig/tests/auto_submenu/__init__.py     |  12 +
 scripts/kconfig/tests/auto_submenu/expected_stdout |  10 +
 scripts/kconfig/tests/choice/Kconfig               |  54 ++++
 scripts/kconfig/tests/choice/__init__.py           |  40 +++
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
 scripts/kconfig/tests/conftest.py                  | 291 +++++++++++++++++++++
 scripts/kconfig/tests/err_recursive_inc/Kconfig    |   1 +
 .../kconfig/tests/err_recursive_inc/Kconfig.inc    |   1 +
 .../kconfig/tests/err_recursive_inc/__init__.py    |  10 +
 .../tests/err_recursive_inc/expected_stderr        |   4 +
 scripts/kconfig/tests/inter_choice/Kconfig         |  24 ++
 scripts/kconfig/tests/inter_choice/__init__.py     |  14 +
 scripts/kconfig/tests/inter_choice/defconfig       |   1 +
 scripts/kconfig/tests/inter_choice/expected_config |   4 +
 scripts/kconfig/tests/new_choice_with_dep/Kconfig  |  37 +++
 .../kconfig/tests/new_choice_with_dep/__init__.py  |  14 +
 scripts/kconfig/tests/new_choice_with_dep/config   |   3 +
 .../tests/new_choice_with_dep/expected_stdout      |  10 +
 .../kconfig/tests/no_write_if_dep_unmet/Kconfig    |  14 +
 .../tests/no_write_if_dep_unmet/__init__.py        |  19 ++
 scripts/kconfig/tests/no_write_if_dep_unmet/config |   1 +
 .../tests/no_write_if_dep_unmet/expected_config    |   5 +
 scripts/kconfig/tests/pytest.ini                   |   6 +
 scripts/kconfig/tests/rand_nested_choice/Kconfig   |  33 +++
 .../kconfig/tests/rand_nested_choice/__init__.py   |  16 ++
 .../tests/rand_nested_choice/expected_stdout0      |   2 +
 .../tests/rand_nested_choice/expected_stdout1      |   4 +
 .../tests/rand_nested_choice/expected_stdout2      |   5 +
 scripts/kconfig/tests/warn_recursive_dep/Kconfig   |  62 +++++
 .../kconfig/tests/warn_recursive_dep/__init__.py   |   9 +
 .../tests/warn_recursive_dep/expected_stderr       |  30 +++
 46 files changed, 897 insertions(+), 3 deletions(-)
 create mode 100644 scripts/kconfig/tests/auto_submenu/Kconfig
 create mode 100644 scripts/kconfig/tests/auto_submenu/__init__.py
 create mode 100644 scripts/kconfig/tests/auto_submenu/expected_stdout
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
 create mode 100644 scripts/kconfig/tests/inter_choice/Kconfig
 create mode 100644 scripts/kconfig/tests/inter_choice/__init__.py
 create mode 100644 scripts/kconfig/tests/inter_choice/defconfig
 create mode 100644 scripts/kconfig/tests/inter_choice/expected_config
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/Kconfig
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/__init__.py
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/config
 create mode 100644 scripts/kconfig/tests/new_choice_with_dep/expected_stdout
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/Kconfig
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/__init__.py
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/config
 create mode 100644 scripts/kconfig/tests/no_write_if_dep_unmet/expected_config
 create mode 100644 scripts/kconfig/tests/pytest.ini
 create mode 100644 scripts/kconfig/tests/rand_nested_choice/Kconfig
 create mode 100644 scripts/kconfig/tests/rand_nested_choice/__init__.py
 create mode 100644 scripts/kconfig/tests/rand_nested_choice/expected_stdout0
 create mode 100644 scripts/kconfig/tests/rand_nested_choice/expected_stdout1
 create mode 100644 scripts/kconfig/tests/rand_nested_choice/expected_stdout2
 create mode 100644 scripts/kconfig/tests/warn_recursive_dep/Kconfig
 create mode 100644 scripts/kconfig/tests/warn_recursive_dep/__init__.py
 create mode 100644 scripts/kconfig/tests/warn_recursive_dep/expected_stderr

-- 
2.7.4

