From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Feb 2001 18:51:46 +0000
Subject: Re: [Linux-ia64] Re: Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005179@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005178@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005178@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Feb 2001 13:12:41 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> David Mosberger (davidm@hpl.hp.com) said:
  >> Please be more specific when reporting bugs.  At the least,
  >> include (a) what type of machine and (b) what kernel patch you
  >> were running at the time.  Ideally, also describe what you where
  >> doing at the time and try to get a backtrace with kdb, if
  >> possible.

  Bill> 2P BigSur, using UP 010131 kernel, on top of 2.4.1-ac16
  Bill> (certainly, this could cause problems).

Thanks for the info.  I haven't looked at or tried the ac patches, so
I don't know whether they are safe for IA-64.

  Bill> As to what I was doing, in one case, nothing at all, in
  Bill> another, untarring a tarball. The video shuts off and the
  Bill> machine is completely dead, which makes diagnosing what
  Bill> happened difficult (hm, need to find serial cable.)

By completely dead you mean that it responded neither on the console
nor to network pings?

  Bill> Since it has happened when I wasn't watching the machine
  Bill> intently, it's entirely possible it's related to when it turns
  Bill> off the monitor via DPMS, but that would just be weird.

Don't know if that has been tested.  Any of the X experts know?

I have my Big Sur configured to run OpenGL screen savers as i figured
that would be a good way to test long term stability even when I'm not
actively using it.  No problems so far.

	--david

