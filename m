From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 May 2003 17:49:58 +0000
Subject: Re: [Linux-ia64] Re: [BK PATCH] SN update
Message-Id: <marc-linux-ia64-105590723705901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705890@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705890@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 May 2003 08:09:01 -0400, Martin Hicks <mort@wildopensource.com> said:

  Martin> On Thu, May 15, 2003 at 11:37:00PM -0700, David Mosberger
  Martin> wrote:
  >> [Forgot to cc the list.]
  >> 
  Jesse> Ok, this is my first 'bksend' cset, so please let me know if
  Jesse> you need something different.
  >>  Please don't do that.  Either send regular patches or point me
  >> to a tree I can pull from (actually, I still need to learn how to
  >> do this "safely").

  Martin> I think it's "safe" to bk pull from anywhere.  There is
  Martin> always bk unpull if you want to reverse the last pull.

That's not safe in my mind.  What I'd like is an efficient way to
preview a pull (see a diff -u between the remote tree and where I'm
pulling into).  Note the "efficient" part.  Having to do a full clone
first doesn't qualify.

	--david

