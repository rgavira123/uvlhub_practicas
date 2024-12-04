from app.modules.discord_bot.models import DiscordBot
from core.repositories.BaseRepository import BaseRepository


class DiscordBotRepository(BaseRepository):
    def __init__(self):
        super().__init__(DiscordBot)
