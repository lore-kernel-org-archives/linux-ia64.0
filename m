From: Alex Williamson <alex_williamson@attbi.com>
Date: Fri, 19 Jul 2002 02:56:48 +0000
Subject: [Linux-ia64] new problem with memcpy_mck routines
Message-Id: <marc-linux-ia64-105590701905782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Using the latest memcpy_mck (20020622 + Ken's 7/10 patch) I'm seeing
problems with screen corruption on VGA.  Here's the test; on a VGA
console, start vim (colorized syntax highlighting and all), edit a
large file (several screens).  Scroll down through the file.  You'll
notice the screen gets corrupted, appears to be columns down the screen
that scroll faster than others.  I'm using an HP McKinley system and
have light switched tested by building w/ the old Itanium routines.
Other apps like less, nvi, etc... don't seem to trigger this.  Thanks,

	Alex


