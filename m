From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Mon, 15 Jan 2007 09:59:15 +0000
Subject: Disparity between esi.c & esi.h
Message-Id: <5e0a1fd80701150147i666f76dp9292a77d1fa9d3cf@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

esi.h has the following extern with no corresponding definition in esi.c
extern int ia64_esi_init (void);

The closest definition in esi.c is the following:
static int __init esi_init (void)
{
...
}

Is this an oversight or am I missing something? I am looking at the
2.6.19 sources.

Thanks & Regards,
Karthik
