from flask import render_template
from app.modules.discord_bot import discord_bot_bp


@discord_bot_bp.route('/discord_bot', methods=['GET'])
def index():
    return render_template('discord_bot/index.html')
