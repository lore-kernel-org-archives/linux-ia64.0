From: Bill Nottingham <notting@redhat.com>
Date: Mon, 19 Mar 2001 20:09:11 +0000
Subject: [Linux-ia64] Re: RH7.1 beta (fisher) for IA64 and Lion
Message-Id: <marc-linux-ia64-105590693005299@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tantilov, EmilX (emilx.tantilov@intel.com) said: 
> I couldn't install the latest RH distribution for IA64 on Lion. Seems like
> it fails when starting the X server. No problems with BigSur. Any ideas?

X in the Fisher beta doesn't work at all on (most) Lions. This is
fixed in our current X packages. You can always pass 'text' to the
installer to install in text mode.

Bill

