From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Oct 2003 20:46:56 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106573247319897@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Oct 2003 14:55:29 +1000, Nathan Scott <nathans@sgi.com> said:

  Nathan> On Wed, Oct 08, 2003 at 08:53:37PM -0700, David Mosberger wrote:
  >> >>>>> On Thu, 9 Oct 2003 13:15:01 +1000, Nathan Scott <nathans@sgi.com> said:

  Nathan> I did not review every possible interface for use of ino_t,
  Nathan> no.  I suppose that needs to be done, I don't have that kind
  Nathan> of time available just now.

  >> Well, then don't be surprised if it doesn't get fixed!

  Nathan> s/fixed/merged/

  Nathan> I'm not surprised, and I can understand your position.  I'll
  Nathan> come back to do an audit when I can, if noone beats me to it
  Nathan> in the meantime.

I doubt anyone will beat you to it.  I don't think the audit should
take a huge amount of time.  Perhaps half to a full day, just to make
sure we're not missing something subtle (such as ioctl()s or something
like that).

Also, note that the time window of making this change for 2.6 is
closing quickly.  Once 2.6.0 is out, it would be 2.7 material.

	--david
