From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Nov 2003 18:38:39 +0000
Subject: making unwcheck.sh
Message-Id: <marc-linux-ia64-106883536806062@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is anybody willing/capable/interested in fixing unwcheck.sh so it can
actually handle 64-bit addresses?  I'm not much of an awk hacker but I
noticed that the only reason the script works on the kernel is because
it drops the first digit of each address (look for gsub() to see what
I mean).  Of course, that makes it work on the kernel, but it won't
work for checking a shared object, for example.  Perhaps the whole
script should just be converted to a real[1] language?


	--david

[1] real = anything other than awk, perl, or tcl... ;-)
