From: Ronald Veldema <veldema@cs.fau.de>
Date: Sat, 10 May 2003 03:11:39 +0000
Subject: [Linux-ia64] executable data segment ?
Message-Id: <marc-linux-ia64-105590723705718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
	Is there a way in linux on ia64 to execute code in the
datasegment ? My Java compiler generates code to the datasegment
for to dynamically remove tests to see if a classes'
static-variables have already been initialized.
Works great on ia32, on linux/ia64 won't allow it...
Ronald.


