require 'rails_helper'
require_relative '../../../app/models/apps/ep_vote_app/application_form'

def start
  visit apps_parliament_vote_app_application_forms_path
  click_button 'Súhlasím a chcem začať'
end

RSpec.feature "Parliament vote app", type: :feature do
  before do
    travel_to Apps::ParliamentVoteApp::ApplicationForm::VOTE_DATE - 1.month
  end

  scenario 'As a citizen I want to request voting permit via post' do
    start

    choose 'Áno'
    click_button 'Pokračovať'

    choose 'Na Slovensku, mimo trvalého bydliska'
    click_button 'Pokračovať'

    choose 'Emailom'
    click_button 'Pokračovať'

    fill_in 'Meno, priezvisko, titul', with: 'Ferko Mrkva'
    fill_in 'Rodné číslo', with: '123'
    fill_in 'Ulica a číslo', with: 'Pupavova 31'
    fill_in 'PSČ', with: '456'
    fill_in 'Obec', with: 'Bratislava - Karlova ves'
    click_button 'Pokračovať'

    choose 'Na adresu trvalého bydliska'
    click_button 'Pokračovať'

    expect(page).to have_content('Meno: Ferko Mrkva')
    expect(page).to have_content('Rodné číslo: 123')
    expect(page).to have_content('Trvalý pobyt: Pupavova 31, 456 Bratislava - Karlova ves')

    click_link 'pokračujte ďalej'
    expect(page).to have_content('Gratulujeme')
  end

  scenario 'As a citizen I want to request voting permit via post to a different address' do
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'Na Slovensku, mimo trvalého bydliska'
    click_button 'Pokračovať'

    choose 'Emailom'
    click_button 'Pokračovať'

    fill_in 'Meno, priezvisko, titul', with: 'Ferko Mrkva'
    fill_in 'Rodné číslo', with: '123'
    fill_in 'Ulica a číslo', with: 'Pupavova 31'
    fill_in 'PSČ', with: '456'
    fill_in 'Obec', with: 'Bratislava - Karlova ves'
    click_button 'Pokračovať'

    choose 'Na inú adresu'
    fill_in 'Ulica a číslo', with: 'Konvalinkova 3'
    fill_in 'PSČ', with: '456'
    fill_in 'Obec', with: 'Bratislava - Ruzinov'
    fill_in 'Štát', with: 'Slovensko'
    click_button 'Pokračovať'

    expect(page).to have_content('Meno: Ferko Mrkva')
    expect(page).to have_content('Rodné číslo: 123')
    expect(page).to have_content('Trvalý pobyt: Pupavova 31, 456 Bratislava - Karlova ves')

    expect(page).to have_content('Preukaz prosím zaslať na korešpondenčnú adresu: Konvalinkova 3, 456 Bratislava - Ruzinov, Slovensko')

    click_link 'pokračujte ďalej'
    expect(page).to have_content('Gratulujeme')
  end

  scenario 'As a citizen I want to request voting permit by post after the deadline' do
    travel_to Apps::ParliamentVoteApp::ApplicationForm::DELIVERY_BY_POST_DEADLINE_DATE + 1.day
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'Na Slovensku, mimo trvalého bydliska'
    click_button 'Pokračovať'

    choose 'Emailom'
    click_button 'Pokračovať'

    expect(page).to have_content('Termín na zaslanie hlasovacieho preukazu poštou už uplynul')
  end

  scenario 'As a citizen I want to request voting permit personaly' do
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'Na Slovensku, mimo trvalého bydliska'
    click_button 'Pokračovať'

    choose 'Osobne'
    click_button 'Pokračovať'

    expect(page).to have_content('Prevzatie hlasovacieho preukazu osobne')
  end

  scenario 'As a citizen I want to request voting permit via authorized person' do
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'Na Slovensku, mimo trvalého bydliska'
    click_button 'Pokračovať'

    choose 'Vyzdvihne ho splnomocnena osoba'
    click_button 'Pokračovať'

    expect(page).to have_content('Prevzatie hlasovacieho preukazu splnomocnenou osobou')
  end

  scenario 'As a citizen I want to vote at home address' do
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'Na Slovensku, v mieste trvalého bydliska'
    click_button 'Pokračovať'

    expect(page).to have_content('Nepotrebujete nič vybavovať')
  end

  scenario 'As a citizen I want to vote in foregin country with permanent residency in Slovakia' do
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'V zahraničí'
    click_button 'Pokračovať'

    choose 'Áno'
    click_button 'Pokračovať'

    expect(page).to have_content('Žiadosť o voľbu poštou pre voľby do Národnej rady Slovenskej republiky je potrebné doručiť svojej obci v mieste trvalého bydliska najneskôr do 50 dní pred dňom konania volieb')
  end

  scenario 'As a citizen I want to vote in foregin country with permanent residency outside Slovakia' do
    start
    choose 'Áno'
    click_button 'Pokračovať'

    choose 'V zahraničí'
    click_button 'Pokračovať'

    choose 'Nie'
    click_button 'Pokračovať'

    expect(page).to have_content('K žiadosti je potrebné pripojiť fotokópiu časti cestovného dokladu Slovenskej republiky s osobnými údajmi voliča alebo fotokópiu osvedčenia o štátnom občianstve Slovenskej republiky.')
  end

  scenario "As a non-SK citizen I can't vote in parliament votes" do
    start
    choose 'Nie'
    click_button 'Pokračovať'

    expect(page).to have_content('V parlamentných voľbách nemôžete voliť.')
  end

  scenario 'As a citizen I want to see subscription options when vote is not active' do
    travel_to Apps::ParliamentVoteApp::ApplicationForm::VOTE_DATE + 1.day
    visit apps_parliament_vote_app_application_forms_path

    expect(page).to have_content('Voľby do parlamentu sa už konali')
    expect(page).to have_content('Chcem dostávať upozornenia k voľbám')
  end
end
