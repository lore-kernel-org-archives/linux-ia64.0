From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jan 2005 02:10:36 +0000
Subject: Re: About intercepting linux system call
Message-Id: <16889.40732.94252.216203@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b3b26beb05012620543066d40@mail.gmail.com>
In-Reply-To: <b3b26beb05012620543066d40@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 Jan 2005 10:04:33 +0800, JinShan Xiong <jinshan.xiong@gmail.com> said:

  JinShan> Hi David, I don't know how to use the stub code, I have
  JinShan> tried to copy it to overload sys_gettimeofday(), like this,

  JinShan>  memcpy(sys_call_table[__NR_gettimeofday - 1024],
  JinShan> new_time_stub, 32),

  JinShan> it crashed the kenrel also.

  JinShan> Please help me!

sys_call_table[__NR_gettimeofday - 1024] would have to be set to the
entry-point of new_time_stub.  If you declare new_time_stub as a
function, you'd have to do this like so:

	extern void new_time_stub (whatever...);
	struct fptr { void *ip, void *gp };

	sys_call_table[__NR_gettimeofday - 1024] 		((struct fptr *) &new_time_stub)->ip;

  --david

