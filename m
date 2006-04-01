From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Sat, 01 Apr 2006 03:40:44 +0000
Subject: power consumption trivia
Message-Id: <ed5aea430603311940l7d07e1e2rb9eb7363566e1279@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In case you ever wondered how much power your Itanium machine draws, here are
measurements for 2 "random" machines, measured with a P4400 Kill A
Watt^{TM} meter:

                                                                      
         plugged in:  booted:   make -j4:
   HP zx2000 (1x900MHz McKinley):                                  10W
    210W      250W
   SGI Prism (2x1.6GHz Madison, 2x ATI X2 graphics):        20W    
377W      385W

I won't vouch for the accuracy of the P4400, but at least it some numbers... ;-)

Enjoy,

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
