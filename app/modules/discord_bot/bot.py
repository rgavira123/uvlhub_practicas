import nextcord
from nextcord.ext import commands
from dotenv import load_dotenv
import os

load_dotenv()

intents = nextcord.Intents.default()
intents.message_content = True

bot = commands.Bot(command_prefix='!', intents=intents)


@bot.command(name='ping')
async def ping(ctx):
    await ctx.send('Pong!')


if __name__ == '__main__':
    bot.run(os.getenv('DISCORD_BOT_TOKEN'))
