From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 15 Oct 2003 22:24:34 +0000
Subject: WAW dependency messages
Message-Id: <marc-linux-ia64-106625678318659@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In case anyone's interested, I just found a gcc bugzilla bug for the
dependency violation stuff that always gets printed when we compile the
kernel.  I've added some information to it.  The bug number is 12287,
and you can see the whole thing at
http://gcc.gnu.org/bugzilla/show_bug.cgi?id287.

Jesse
