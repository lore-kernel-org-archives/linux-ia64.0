From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 21 Sep 2000 23:44:28 +0000
Subject: Re: [Linux-ia64] unregister_rebbot_notifier()
Message-Id: <marc-linux-ia64-105590678205514@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205511@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205511@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 21 Sep 2000 14:03:51 -0700, 
"Randall G Chan/Fremont/IBM" <chanr@us.ibm.com> wrote:
>Also, I can't seem to get this module to load on 2.4.0-test8.  This system
>just seems to hang after trying to insert the module.  I've seen this
>happen on the same two machines listed above.  Are there any known problems
>in test8 in relation to module loading?

Please try modutils 2.3.16 plus the patch at
ftp://ftp.ocs.com.au/private/modutils-2.3.16-patch-1, let me know if it
works so I can release it as modutils 2.3.17.


