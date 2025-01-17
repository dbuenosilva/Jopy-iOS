//
//  LoginViewController.m
//  Jopy
//
//  Created by Edson Teco on 13/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import "LoginViewController.h"
#import "Sessao.h"
#import "AppDelegate.h"

#define kKEY_SEGUE_HOME @"homeSegue"

@interface LoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UITextField *txtLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtSenha;
@property (weak, nonatomic) IBOutlet UIButton *btnEntrar;
@property (weak, nonatomic) IBOutlet UIButton *btnRecuperarSenha;

@property (nonatomic) CGFloat keyboardOverlap;
@property (strong, nonatomic) UITextField *currentResponder;

@property (weak, nonatomic) IBOutlet UIImageView *imgCheck;

@property (weak, nonatomic) IBOutlet UIView *faixaInferior;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightFaixaInferior;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthImgCheck;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightImgCheck;

@end

@implementation LoginViewController

#pragma mark -
#pragma mark Getters overriders

- (AppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return _appDelegate;
}

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Metodos publicos

#pragma mark -
#pragma mark Metodos privados

/**
 *  Método responsável para esconder o teclado caso algum campo esteja com foco
 */
- (void)escondeTeclado
{
    if (self.currentResponder) [self.currentResponder resignFirstResponder];
}

/**
 *  Método responsável por configurar os itens da UI
 */
- (void)configuraInterface
{
    self.txtLogin.tag = 1;
    self.txtLogin.delegate = self;
    
    self.txtSenha.tag = 2;
    self.txtSenha.delegate = self;
    
    [self.btnEntrar setTintColor:COR_AMARELO];
    [self.btnRecuperarSenha setTintColor:COR_BRANCO];
    
    // Configura o TAP para esconder o teclado
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(fundoTapped:)];
    [self.view addGestureRecognizer:tap];
    
    self.container.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = COR_DEGRADE_INICIAL;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[COR_DEGRADE_INICIAL CGColor], (id)[COR_DEGRADE_FINAL CGColor], (id)[COR_DEGRADE_INICIAL CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    [self viabilizaMostrarImagemAbaixoDoLogin];
    
    [self atualizaDegrade];
}

/**
 * Atualiza o degrade conforme tamanho da view
 */
- (void)atualizaDegrade
{
    [self.view layoutIfNeeded];
    [self.faixaInferior layoutIfNeeded];
    
    CGRect frame = self.view.frame;
    CGFloat tamanho = ([self screenSize].height>[self screenSize].width)?[self screenSize].height:[self screenSize].width;
    frame.size.height = tamanho;
    frame.size.width = tamanho;
    [[[self.view.layer sublayers] objectAtIndex:0] setFrame:frame];

    CAGradientLayer *gradientFaixaInferior = [CAGradientLayer layer];
    gradientFaixaInferior.frame = self.faixaInferior.bounds;
    frame = gradientFaixaInferior.frame;
    frame.size.width = tamanho;
    gradientFaixaInferior.frame = frame;
    gradientFaixaInferior.startPoint = CGPointMake(0.0, 0.5);
    gradientFaixaInferior.endPoint = CGPointMake(1.0, 0.5);
    gradientFaixaInferior.colors = [NSArray arrayWithObjects:(id)[COR_DEGRADE_INICIAL_INFERIOR CGColor], (id)[COR_DEGRADE_FINAL_INFERIOR CGColor], nil];
    
    [self.faixaInferior.layer insertSublayer:gradientFaixaInferior atIndex:(unsigned int)self.faixaInferior.layer.sublayers.count];
}

/**
 * Verifica o espaço disponível entre a base do container do login e a parte inferior da tela para ver se cabe a imagem
 */
- (void)viabilizaMostrarImagemAbaixoDoLogin
{
    self.constraintHeightImgCheck.constant = 110;
    self.constraintWidthImgCheck.constant = 110;
    self.constraintHeightFaixaInferior.constant = 32;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            self.constraintHeightImgCheck.constant = 95;
            self.constraintWidthImgCheck.constant = 95;
            self.constraintHeightFaixaInferior.constant = 16;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 667) {
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 736) {
            
        }
        else {
            self.constraintHeightImgCheck.constant = 65;
            self.constraintWidthImgCheck.constant = 65;
            self.constraintHeightFaixaInferior.constant = 16;
        }
    }
    else {
        self.constraintHeightImgCheck.constant = 120;
        self.constraintWidthImgCheck.constant = 120;
        self.constraintHeightFaixaInferior.constant = 56;
    }
    
    [self.imgCheck layoutIfNeeded];
    [self.faixaInferior layoutIfNeeded];
    [self.container layoutIfNeeded];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.imgCheck.alpha = ([self screenSize].height - (self.container.frame.origin.y + self.container.frame.size.height) >= self.imgCheck.frame.size.height)?1.0:0.0;
    }];
}

/**
 * Efetua o ajuste em Y das views. Normalmente para animar a entrada do teclado
 *
 * @param CGFloat yOffset Offset em Y
 * @param CGFloat duration Duracao da animacao em segundos
 * @param block bloco para ser executado ao terminar a animacao
 */
- (void)adjustCommentViewYPosition:(CGFloat)yOffset duration:(CGFloat)duration animationType:(UIViewAnimationOptions)animationOptions completion:(void (^)(BOOL finished))block
{
    CGRect frame;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        frame = self.view.frame;
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            frame.origin.x = yOffset;
        }
        else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            frame.origin.x = -yOffset;
        }
        else if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            frame.origin.y = yOffset;
        }
        else if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            frame.origin.y = -yOffset;
        }
    }
    else {
        frame = self.view.frame;
        frame.origin.y = yOffset;
    }
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         self.view.frame = frame;
                     }
                     completion: block];

}

/**
 *  Método para retornar o tamanho total da interface. Resolve a diferença que o iOS 7 e o iOS 8 trata.
 *
 *  @return CGSize da tela
 */
- (CGSize)screenSize
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

/**
 *  Método que trata o TAP da view e esconde o teclado
 *
 *  @param sender Gesto que disparou o método
 */
- (void)fundoTapped:(id)sender
{
    [self escondeTeclado];
}

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.keyboardOverlap = 120; // altura que o form deve ser movimentado ao mostrar o teclado
    
    [self configuraInterface];
    
    self.txtLogin.text = [Sessao login];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    debug(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Registro do observer para ser chamado quando o teclado for acionado
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove o observer das notificações
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Atualiza o degradé ao rotacionar
    [self atualizaDegrade];
    
    [self viabilizaMostrarImagemAbaixoDoLogin];
}

#pragma mark -
#pragma mark Storyboards Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kKEY_SEGUE_HOME]) {
        UITabBarController *tabBarController = segue.destinationViewController;
        [self.appDelegate configuraTabs:tabBarController];
    }
}

#pragma mark -
#pragma mark Target/Actions

- (IBAction)entrar:(id)sender
{
    [self mostraHudComTexto:@"Aguarde"];
    
    // guarda o login para ficar preenchido
    [Sessao definirLogin:self.txtLogin.text];
    
    [Sessao efetuaLogin:self.txtLogin.text senha:self.txtSenha.text completion:^(bool sucesso, NSString *mensagem) {
        
        [self escondeHud];
        
        if (sucesso) {
            self.txtSenha.text = @"";
            
            // Após o login, inicia o download dos dados
            [self.appDelegate.webServiceDataModel obtemNovosDados];
            
            [self performSegueWithIdentifier:kKEY_SEGUE_HOME sender:nil];
        }
        else {
            [Sessao showMessage:mensagem title:@"Login"];
        }
    }];
}

- (IBAction)recuperarSenha:(id)sender
{
    if (self.txtLogin.text.length == 0) {
        [Sessao showMessage:@"Informe seu login para recuperar a senha" title:@"Recuperar Senha" completion:^{
            [self.txtLogin becomeFirstResponder];
        }];
    }
    else {
        [Sessao recuperaSenha:self.txtLogin.text completion:^(bool sucesso, NSString *mensagem) {
            if (sucesso) {
                [Sessao showMessage:mensagem title:@"Recuperar Senha"];
            }
            else {
                [Sessao showMessage:mensagem title:@"Recuperar Senha"];
            }
        }];
    }
}

#pragma mark -
#pragma mark Delegates

#pragma mark UITextFieldDelegate

/**
 *  Método que é disparado toda vez que um campo receber foco.
 *
 *  @param textField Campo que recebeu foco
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentResponder = textField;
}

/**
 *  Método que é disparado toda vez que se pressiona o ENTER
 *
 *  @param textField TextField que está com foco
 *
 *  @return YES para escrever o ENTER ou NO para cancelar
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [self escondeTeclado];
        
        [self entrar:nil];
    }
    return NO; // Para não inserir line-breaks.
}

#pragma mark -
#pragma mark Notification center

- (void)keyboardWillShow:(NSNotification *)notification
{
    // pega infos sobre o teclado e sua animacao
    CGRect keyboardEndFrame = CGRectZero;
    NSTimeInterval animationDuration = 0.0;
    UIViewAnimationOptions animationType = UIViewAnimationOptionCurveEaseInOut;
    
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationType];
    
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    [self adjustCommentViewYPosition:-80.0
                            duration:0.5
                       animationType:UIViewAnimationOptionCurveEaseInOut
                          completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // pega infos sobre o teclado e sua animacao
    NSTimeInterval animationDuration = 0.0;
    UIViewAnimationOptions animationType = UIViewAnimationOptionCurveEaseInOut;
    
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationType];
    
    [self adjustCommentViewYPosition:0.0
                            duration:animationDuration
                       animationType:UIViewAnimationOptionCurveEaseInOut
                          completion:nil];
}

@end
