From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 02 Oct 2001 03:37:05 +0000
Subject: Re: [Linux-ia64] Re: kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 1 Oct 2001 14:14:06 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Chris Ahna (christopher.j.ahna@intel.com) said:
  >> Well, I do now :-) On ia64 we want to map even AGP memory as
  >> writecombined.  The appended patch should fix the rendering
  >> problems Bill reported earlier.

  Bill> Yup, works great. Running ia32 glxinfo appears to crash the X
  Bill> server, though...

Speaking of the X server: I recently tried the stuff in the "rawhide"
directory (XFree 4.1.0).  The X server *still* easily crashes the
machine when switching back between the X server and the virtual
consoles.  This is very painful.  I hope someone can find some time to
look into this.  (By "crash" I mean "instant reboot".)

	--david

