From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Sep 2002 18:48:47 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906056@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Sep 2002 13:35:43 -0500, Nathan Straz <nstraz@sgi.com> said:

  Nathan> On Wed, Sep 25, 2002 at 02:18:51PM -0400,
  Nathan> Sane_Purushottam@emc.com wrote:
  >> What is the preferred method to determine the platform at run
  >> time ?? Are these values likely to change (after I change my code
  >> to handle this) ????

  Nathan> I had to do the same thing for an application and I ended up
  Nathan> forking off a process to run the uname command.

That doesn't work.  On a properly configured machine,
execve("/bin/uname") will return i686 when execute from an x86
process.

	--david

