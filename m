From: "shiva chetan" <chetan@uiuc.edu>
Date: Wed, 13 Nov 2002 18:42:20 +0000
Subject: [Linux-ia64] sigcontext structure
Message-Id: <marc-linux-ia64-105590709805410@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The sigcontext structure of linux/i386 has the following fields

trapno (stores trap number)
err   (stores faulting address)
cr2  (contains type of fault)

what are the equivalent fields in the sigcontext structure of linux/ia64 ?
its not very apparent from the definition of the structure.

thanks

chetan
Dept of Computer Science
Univ of Illinois at Urbana-Champaign

Ph: (217) 333-9051, (217) 244-5110 (O)
      (217) 384-2173 (R)


