From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 Feb 2005 23:45:25 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02DFB694@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I assume you already checked that I didn't introduce any other stupid
>dereferencing bugs?  I'd do it myself, but I'm still catching up with
>my email backlog...

Whatever bugs are left are subtle, not stupid.  I've been injecting
errors every 20 seconds[1].  I've seen 2 bad things happen so far:

1) My ethernet connection goes down within a dozen errors consistently.
But I think this is an artifact of the error injection technology ... the
same issue happens with 2.6.9

2) I saw one user process failure ... while stressing the system with a
"make -j16" kernel build, one of the complilations error'd out with a
bizarre internal gcc error.  So possibly a register was corrupted???

-Tony

[1] I haven't been running the injector continuously all day at that
rate ... just on and off with different tests running.  But I have
seen a few hundred MCAs recovered in this time.
