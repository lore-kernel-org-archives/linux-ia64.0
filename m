From: Bill Nottingham <notting@redhat.com>
Date: Wed, 25 Sep 2002 19:34:15 +0000
Subject: [Linux-ia64] Re: platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906062@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Van Maren, Kevin (kevin.vanmaren@unisys.com) said: 
> Have you decided what you want to do about AMD's x86-64?
> That is another 64-bit platform that will run your 32-bit binary.
> 
> Ideally all three platforms would be enough alike you don't
> have to worry about it: is there a problem with Linux that is
> causing you to perform this check?

Note that x86-64 is generally not going down the /emul/i386-linux
route, AFAICT.

Bill

