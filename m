From: Bill Nottingham <notting@redhat.com>
Date: Mon, 01 Oct 2001 18:14:06 +0000
Subject: Re: [Linux-ia64] Re: kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chris Ahna (christopher.j.ahna@intel.com) said: 
> Well, I do now :-)  On ia64 we want to map even AGP memory as
> writecombined.  The appended patch should fix the rendering problems
> Bill reported earlier.

Yup, works great. Running ia32 glxinfo appears to crash the X server, though...

Bill

