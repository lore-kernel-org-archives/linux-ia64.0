From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jan 2003 23:38:34 +0000
Subject: Re: [Linux-ia64] IA-32 emulation issues
Message-Id: <marc-linux-ia64-105590709805634@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805630@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805630@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 02 Jan 2003 15:31:04 -0800, Arun Sharma <arun.sharma@intel.com> said:

  Arun> I've done some more debugging on this and I think there is no problem
  Arun> with getdents/getdents64.

  Arun> The problem was with a test case that did pwrite(2) with offset = -1
  Arun> and it was expecting the test to fail. However, on IA-64, the test
  Arun> case passed, leaving this temp file on the disk:

  Arun> $ ls -l /tmp/pwrbcneW5/pwrite_file 
  Arun> -rw-r--r--    1 tester tester 4294968319 Jan  2 15:34 /tmp/pwrbcneW5/pwrite_file

  Arun> Subsequently, the test harness tries to cleanup the file and does a
  Arun> lstat on it, which results in EOVERFLOW.

I think this has been fixed in 2.5 already: the problem was that the
x86 version of sys_open() ended up turning on the O_LARGEFILE flag,
which was wrong (I think Andi Kleen pointed this out, originally).
The fix was to add the sys32_open() wrapper.  I don't recall if this
has been added to 2.4.xx already.  If not, it probably ought to be
added.

	--david

