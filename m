From: Bill Nottingham <notting@redhat.com>
Date: Thu, 21 Sep 2000 21:15:55 +0000
Subject: [Linux-ia64] Re: unregister_rebbot_notifier()
Message-Id: <marc-linux-ia64-105590678205512@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Randall G Chan/Fremont/IBM (chanr@us.ibm.com) said: 
> Also, I can't seem to get this module to load on 2.4.0-test8.  This system
> just seems to hang after trying to insert the module.  I've seen this
> happen on the same two machines listed above.  Are there any known problems
> in test8 in relation to module loading?

I'm seeing any module hanging when init_module is called. 

Bill

