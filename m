From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 25 Apr 2000 14:43:56 +0000
Subject: Re: [Linux-ia64] Bug report: two 'kills' kill the shell
Message-Id: <marc-linux-ia64-105590678205041@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205029@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205029@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I can't reproduce this on 2.3.99-pre5 (SMP).  Please try the latest
kernel.  There was a fix to asynchronous signal delivery in the 2.3.51
patches.

	--david

>>>>> On Mon, 24 Apr 2000 16:31:40 -0700 (PDT), David Robboy <robboy@co.intel.com> said:

  David> On MP linux 2.3.47 for ia64 running on a 4-processor system,
  David> with this program:

  David> main() { while(1) { sleep(2); printf("Hello world\n"); } }

  David> I started up 4 of them in background from one shell.  Then
  David> went to another window and started killing them with the
  David> 'kill' command (not kill 9, just plain kill).  The second
  David> 'kill' kills the shell, consistently.  It looks like maybe
  David> the shell can handle one SIGCHILD but not two of them.

  David> David Robboy



  David> _______________________________________________ Linux-IA64
  David> mailing list Linux-IA64@linuxia64.org
  David> http://lists.linuxia64.org/lists/listinfo/linux-ia64


